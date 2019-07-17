//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import AVFoundation
import Common
import CoreData
import Foundation
import UIKit

final class StreamPersistenceManager: NSObject, PersistenceManager {

    typealias Session = AVAssetDownloadURLSession

    static let shared = StreamPersistenceManager()
    static let downloadType = "stream"
    static let titleForFailedDownloadAlert = NSLocalizedString("alert.download-error.stream.title",
                                                               comment: "title of alert for stream download errors")

    let keyPath: ReferenceWritableKeyPath<Video, NSData?> = \Video.localFileBookmark

    var activeDownloads: [URLSessionTask: String] = [:]
    var progresses: [String: Double] = [:]
    var didRestorePersistenceManager: Bool = false
    var willDownloadToUrlMap: [URLSessionTask: URL] = [:]

    lazy var persistentContainerQueue = self.createPersistenceContainerQueue()
    lazy var session: AVAssetDownloadURLSession = {
        let sessionIdentifier = "asset-download"
        let backgroundConfiguration = URLSessionConfiguration.background(withIdentifier: sessionIdentifier)
        return AVAssetDownloadURLSession(configuration: backgroundConfiguration, assetDownloadDelegate: self, delegateQueue: OperationQueue.main)
    }()

    var fetchRequest: NSFetchRequest<Video> {
        return Video.fetchRequest()
    }

    override init() {
        super.init()
        self.startListeningToDownloadProgressChanges()
    }

    func downloadTask(with url: URL, for resource: Video, on session: AVAssetDownloadURLSession) -> URLSessionTask? {
        let assetTitleCourse = resource.item?.section?.course?.slug ?? "Unknown course"
        let assetTitleItem = resource.item?.title ?? "Untitled video"
        let assetTitle = "\(assetTitleItem) (\(assetTitleCourse))".safeAsciiString() ?? "Untitled video"
        let asset = AVURLAsset(url: url)
        let options = [AVAssetDownloadTaskMinimumRequiredMediaBitrateKey: UserDefaults.standard.videoQualityForDownload.rawValue]

        if #available(iOS 11, *) {
            return session.aggregateAssetDownloadTask(with: asset,
                                                      mediaSelections: asset.allMediaSelections,
                                                      assetTitle: assetTitle,
                                                      assetArtworkData: resource.posterImageData,
                                                      options: options)
        } else {
            return session.makeAssetDownloadTask(asset: asset,
                                                 assetTitle: assetTitle,
                                                 assetArtworkData: resource.posterImageData,
                                                 options: options)
        }
    }

    func startDownload(for video: Video) {
        guard let url = video.streamURLForDownload else { return }
        self.startDownload(with: url, for: video)
    }

    func downloadLocation(for task: URLSessionTask) -> URL? {
        return self.willDownloadToUrlMap[task]
    }

    func resourceModificationAfterStartingDownload(for resource: Video) {
        resource.downloadDate = Date()
    }

    func resourceModificationAfterDeletingDownload(for resource: Video) {
        resource.downloadDate = nil
    }

    private func trackingContext(for video: Video) -> [String: String?] {
        return [
            "section_id": video.item?.section?.id,
            "course_id": video.item?.section?.course?.id,
            "video_download_pref": String(describing: UserDefaults.standard.videoQualityForDownload.rawValue),
        ]
    }

    func didStartDownload(for resource: Video) {
        TrackingHelper.shared.createEvent(.videoDownloadStart, resourceType: .video, resourceId: resource.id, context: self.trackingContext(for: resource))
    }

    func didCancelDownload(for resource: Video) {
        TrackingHelper.shared.createEvent(.videoDownloadCanceled, resourceType: .video, resourceId: resource.id, context: self.trackingContext(for: resource))
    }

    func didFinishDownload(for resource: Video) {
        TrackingHelper.shared.createEvent(.videoDownloadFinished, resourceType: .video, resourceId: resource.id, context: self.trackingContext(for: resource))
    }

}

extension StreamPersistenceManager {

    func offlinePlayableAsset(for video: Video) -> AVURLAsset? {
        guard let localFileLocation = self.localFileLocation(for: video) else {
            return nil
        }

        let asset = AVURLAsset(url: localFileLocation)
        return asset.assetCache?.isPlayableOffline == true ? asset : nil
    }

}

extension StreamPersistenceManager {

    func startDownloads(for section: CourseSection) {
        self.persistentContainerQueue.addOperation {
            section.items.compactMap { item in
                return item.content as? Video
            }.filter { video in
                return StreamPersistenceManager.shared.downloadState(for: video) == .notDownloaded
            }.forEach { video in
                self.startDownload(for: video)
            }
        }
    }

    func deleteDownloads(for section: CourseSection) {
        self.persistentContainerQueue.addOperation {
            section.items.compactMap { item in
                return item.content as? Video
            }.forEach { video in
                self.deleteDownload(for: video)
            }
        }
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

    @available(iOS, obsoleted: 11.0)
    func urlSession(_ session: URLSession, assetDownloadTask: AVAssetDownloadTask, didFinishDownloadingTo location: URL) {
        self.finishDownloadTask(assetDownloadTask, to: location)
    }

    @available(iOS, obsoleted: 11.0)
    func urlSession(_ session: URLSession,
                    assetDownloadTask: AVAssetDownloadTask,
                    didLoad timeRange: CMTimeRange,
                    totalTimeRangesLoaded loadedTimeRanges: [NSValue],
                    timeRangeExpectedToLoad: CMTimeRange) {
        self.postDownloadProgressChange(forDownloadTask: assetDownloadTask,
                                        totalTimeRangesLoaded: loadedTimeRanges,
                                        timeRangeExpectedToLoad: timeRangeExpectedToLoad)
    }

    @available(iOS 11, *)
    func urlSession(_ session: URLSession,
                    aggregateAssetDownloadTask: AVAggregateAssetDownloadTask,
                    didLoad timeRange: CMTimeRange,
                    totalTimeRangesLoaded loadedTimeRanges: [NSValue],
                    timeRangeExpectedToLoad: CMTimeRange,
                    for mediaSelection: AVMediaSelection) {
        self.postDownloadProgressChange(forDownloadTask: aggregateAssetDownloadTask,
                                        totalTimeRangesLoaded: loadedTimeRanges,
                                        timeRangeExpectedToLoad: timeRangeExpectedToLoad)
    }

    @available(iOS 11, *)
    func urlSession(_ session: URLSession,
                    aggregateAssetDownloadTask: AVAggregateAssetDownloadTask,
                    willDownloadTo location: URL) {
        self.willDownloadToUrlMap[aggregateAssetDownloadTask] = location
    }

    private func postDownloadProgressChange(forDownloadTask downloadTask: URLSessionTask,
                                            totalTimeRangesLoaded loadedTimeRanges: [NSValue],
                                            timeRangeExpectedToLoad: CMTimeRange) {
        guard let videoId = self.activeDownloads[downloadTask] else { return }

        let expectedSecondsToLoad = timeRangeExpectedToLoad.duration.seconds
        let percentComplete = loadedTimeRanges.map { $0.timeRangeValue.duration.seconds / expectedSecondsToLoad }.reduce(0, +)

        var userInfo: [String: Any] = [:]
        userInfo[DownloadNotificationKey.downloadType] = StreamPersistenceManager.downloadType
        userInfo[DownloadNotificationKey.resourceId] = videoId
        userInfo[DownloadNotificationKey.downloadProgress] = percentComplete

        NotificationCenter.default.post(name: DownloadProgress.didChangeNotification, object: nil, userInfo: userInfo)
    }

}

extension StreamPersistenceManager {

    func fileSize(for resource: Video) -> UInt64? {
        guard let url = self.localFileLocation(for: resource) else { return nil }
        return try? FileManager.default.allocatedSizeOfDirectory(at: url)
    }

}
