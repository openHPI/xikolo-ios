//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import AVFoundation
import BrightFutures
import Common
import CoreData

final class StreamPersistenceManager: PersistenceManager<StreamPersistenceManager.Configuration> {

    enum Configuration: PersistenceManagerConfiguration {

        // swiftlint:disable nesting
        typealias Resource = Video
        typealias Session = AVAssetDownloadURLSession
        // swiftlint:enable nesting

        static let keyPath = \Video.localFileBookmark
        static let downloadType = "stream"
        static let titleForFailedDownloadAlert = NSLocalizedString("alert.download-error.stream.title",
                                                                   comment: "title of alert for stream download errors")

        static func newFetchRequest() -> NSFetchRequest<Video> {
            return Video.fetchRequest()
        }

    }

    static let shared = StreamPersistenceManager()

    var backgroundCompletionHandler: (() -> Void)?

    private var assetTitlesForRecourseIdentifiers: [String: String] = [:]
    private var mediaSelectionForDownloadTask: [AVAssetDownloadTask: AVMediaSelection] = [:]

    override func newDownloadSession() -> AVAssetDownloadURLSession {
        let sessionIdentifier = "asset-download"
        let backgroundConfiguration = URLSessionConfiguration.background(withIdentifier: sessionIdentifier)
        return AVAssetDownloadURLSession(configuration: backgroundConfiguration, assetDownloadDelegate: self, delegateQueue: OperationQueue.main)
    }

    override func downloadTask(with url: URL, for resource: Video, on session: AVAssetDownloadURLSession) -> URLSessionTask? {
        let assetTitleCourse = resource.item?.section?.course?.slug ?? "Unknown course"
        let assetTitleItem = resource.item?.title ?? "Untitled video"
        let assetTitle = "\(assetTitleItem) (\(assetTitleCourse))".safeAsciiString() ?? "Untitled video"
        let asset = AVURLAsset(url: url)
        let options = [AVAssetDownloadTaskMinimumRequiredMediaBitrateKey: UserDefaults.standard.videoQualityForDownload.rawValue]

        // Supplementary downloads (likes subtitles) must have the same asset title when creating the download tasks.
        // Therefore, we store the used title for later usage.
        self.assetTitlesForRecourseIdentifiers[resource.id] = assetTitle

        // Using `aggregateAssetDownloadTask(with:mediaSelections:assetTitle:assetArtworkData:options:)` results in downloaded assets
        // that fail to start the playback without an Internet connection. So we are using the consecutive approach introduced in iOS 10.
        return session.makeAssetDownloadTask(asset: asset, assetTitle: assetTitle, assetArtworkData: resource.posterImageData, options: options)
    }

    override func startSupplementaryDownloads(for task: URLSessionTask, with resourceIdentifier: String) -> Bool {
        guard let assetDownloadTask = task as? AVAssetDownloadTask else { return false }
        guard let (mediaSelectionGroup, mediaSelectionOption) = self.nextMediaSelection(assetDownloadTask.urlAsset) else { return false }
        guard let originalMediaSelection = self.mediaSelectionForDownloadTask[assetDownloadTask] else { return false }
        guard let assetTitle = self.assetTitlesForRecourseIdentifiers[resourceIdentifier] else { return false }

        guard let mediaSelection = originalMediaSelection.mutableCopy() as? AVMutableMediaSelection else { return false }
        mediaSelection.select(mediaSelectionOption, in: mediaSelectionGroup)

        // Must have the same asset title as the original download task.
        guard let task = self.session.makeAssetDownloadTask(asset: assetDownloadTask.urlAsset,
                                                            assetTitle: assetTitle,
                                                            assetArtworkData: nil,
                                                            options: [AVAssetDownloadTaskMediaSelectionKey: mediaSelection]) else { return false }

        task.taskDescription = resourceIdentifier
        self.activeDownloads[task] = resourceIdentifier
        task.resume()

        return true
    }

    override func resourceModificationAfterStartingDownload(for resource: Video) {
        resource.downloadDate = Date()
    }

    override func resourceModificationAfterDeletingDownload(for resource: Video) {
        resource.downloadDate = nil
    }

    private func trackingContext(for video: Video, options: [Option]) -> [String: String?] {
        var context = [
            "section_id": video.item?.section?.id,
            "course_id": video.item?.section?.course?.id,
            "video_download_pref": String(describing: UserDefaults.standard.videoQualityForDownload.rawValue),
            "free_space": String(describing: StreamPersistenceManager.systemFreeSize),
            "total_space": String(describing: StreamPersistenceManager.systemSize),
        ]

        for case let .trackingContext(additionalContext) in options {
            context.merge(additionalContext) { $1 }
        }

        return context
    }

    override func didStartDownload(for resource: Video, options: [Option]) {
        let trackingContext = self.trackingContext(for: resource, options: options)
        TrackingHelper.createEvent(.videoDownloadStart, resourceType: .video, resourceId: resource.id, on: nil, context: trackingContext)
    }

    override func didCancelDownload(for resource: Video, options: [Option]) {
        let trackingContext = self.trackingContext(for: resource, options: options)
        TrackingHelper.createEvent(.videoDownloadCanceled, resourceType: .video, resourceId: resource.id, on: nil, context: trackingContext)
    }

    override func didFinishDownload(for resource: Video, options: [Option]) {
        let trackingContext = self.trackingContext(for: resource, options: options)
        TrackingHelper.createEvent(.videoDownloadFinished, resourceType: .video, resourceId: resource.id, on: nil, context: trackingContext)
    }

    private func nextMediaSelection(_ asset: AVURLAsset) -> (mediaSelectionGroup: AVMediaSelectionGroup, mediaSelectionOption: AVMediaSelectionOption)? {
        guard let assetCache = asset.assetCache else { return nil }

        let mediaCharacteristics = [AVMediaCharacteristic.audible, AVMediaCharacteristic.legible]

        for mediaCharacteristic in mediaCharacteristics {
            if let mediaSelectionGroup = asset.mediaSelectionGroup(forMediaCharacteristic: mediaCharacteristic) {
                let savedOptions = assetCache.mediaSelectionOptions(in: mediaSelectionGroup)

                if savedOptions.count < mediaSelectionGroup.options.count {
                    // There are still media options left to download.
                    for option in mediaSelectionGroup.options {
                        if !savedOptions.contains(option) && option.mediaType != AVMediaType.closedCaption {
                            // This option has not been download.
                            return (mediaSelectionGroup, option)
                        }
                    }
                }
            }
        }

        // At this point all media options have been downloaded.
        return nil
    }

    override func fileSize(for resource: Video) -> UInt64? {
        guard let url = self.localFileLocation(for: resource) else { return nil }
        return try? FileManager.default.allocatedSizeOfDirectory(at: url)
    }

}

extension StreamPersistenceManager {

    @discardableResult
    func startDownload(for video: Video, options: [StreamPersistenceManager.Option] = []) -> Future<Void, XikoloError> {
        guard let url = video.streamURLForDownload else { return Future(error: .totallyUnknownError) }
        return self.startDownload(with: url, for: video, options: options)
    }

    @discardableResult
    func startDownloads(for section: CourseSection, options: [StreamPersistenceManager.Option] = []) -> Future<Void, XikoloError> {
        let promise = Promise<Void, XikoloError>()

        self.persistentContainerQueue.addOperation {
            let sectionDownloadFuture = section.items.compactMap { item in
                return item.content as? Video
            }.filter { video in
                return self.downloadState(for: video) == .notDownloaded
            }.map { video in
                self.startDownload(for: video, options: options)
            }.sequence().asVoid()

            promise.completeWith(sectionDownloadFuture)
        }

        return promise.future
    }

    @discardableResult
    func deleteDownloads(for section: CourseSection) -> Future<Void, XikoloError> {
        let promise = Promise<Void, XikoloError>()

        let sectionObjectID = section.objectID

        self.persistentContainerQueue.addOperation {
            let sectionDeleteFuture = section.items.compactMap { item in
                return item.content as? Video
            }.map { video in
                self.deleteDownload(for: video)
            }.sequence().asVoid()

            return promise.completeWith(sectionDeleteFuture)
        }

        return promise.future
    }

    func cancelDownloads(for section: CourseSection) {
        self.persistentContainerQueue.addOperation {
            section.items.compactMap { item in
                return item.content as? Video
            }.filter { video in
                return [.pending, .downloading].contains(StreamPersistenceManager.shared.downloadState(for: video))
            }.forEach { video in
                self.cancelDownload(for: video)
            }
        }
    }

}

extension StreamPersistenceManager: AVAssetDownloadDelegate {

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        self.didCompleteDownloadTask(task, with: error)
    }

    func urlSession(_ session: URLSession, assetDownloadTask: AVAssetDownloadTask, didFinishDownloadingTo location: URL) {
        self.didFinishDownloadTask(assetDownloadTask, to: location)
    }

    func urlSession(_ session: URLSession,
                    assetDownloadTask: AVAssetDownloadTask,
                    didLoad timeRange: CMTimeRange,
                    totalTimeRangesLoaded loadedTimeRanges: [NSValue],
                    timeRangeExpectedToLoad: CMTimeRange) {
        guard let videoId = self.activeDownloads[assetDownloadTask] else { return }

        var percentComplete = 0.0
        for value in loadedTimeRanges {
            let loadedTimeRange: CMTimeRange = value.timeRangeValue
            percentComplete += CMTimeGetSeconds(loadedTimeRange.duration) / CMTimeGetSeconds(timeRangeExpectedToLoad.duration)
        }

        var userInfo: [String: Any] = [:]
        userInfo[DownloadNotificationKey.downloadType] = StreamPersistenceManager.Configuration.downloadType
        userInfo[DownloadNotificationKey.resourceId] = videoId
        userInfo[DownloadNotificationKey.downloadProgress] = percentComplete

        NotificationCenter.default.post(name: DownloadProgress.didChangeNotification, object: nil, userInfo: userInfo)
    }

    func urlSession(_ session: URLSession, assetDownloadTask: AVAssetDownloadTask, didResolve resolvedMediaSelection: AVMediaSelection) {
        self.mediaSelectionForDownloadTask[assetDownloadTask] = resolvedMediaSelection
    }

    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        self.backgroundCompletionHandler?()
    }

}
