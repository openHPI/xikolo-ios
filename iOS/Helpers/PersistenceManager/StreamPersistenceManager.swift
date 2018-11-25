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

    static var shared = StreamPersistenceManager()
    static var downloadType = "stream"

    let keyPath: ReferenceWritableKeyPath<Video, NSData?> = \Video.localFileBookmark

    var activeDownloads: [URLSessionTask: String] = [:]
    var progresses: [String: Double] = [:]
    var didRestorePersistenceManager: Bool = false

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

        return session.makeAssetDownloadTask(asset: asset, assetTitle: assetTitle, assetArtworkData: resource.posterImageData, options: options)
    }

    func startDownload(for video: Video) {
        guard let url = video.streamURLForDownload else { return }
        self.startDownload(with: url, for: video)
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

    func didFailToDownloadResource(_ resource: Video, with error: NSError) {
        if error.domain == NSURLErrorDomain && error.code == NSURLErrorCancelled {
            log.debug("Canceled download of video (video id: \(resource.id))")
            return
        }

        ErrorManager.shared.remember((Resource.type, resource.id), forKey: "resource")
        ErrorManager.shared.report(error)
        log.error("Unknown asset download error (video id: \(resource.id) | domain: \(error.domain) | code: \(error.code)")

        // show error
        DispatchQueue.main.async {
            let alertTitle = NSLocalizedString("course-item.stream-download-action.download-error.title",
                                               comment: "title to download error alert")
            let alertMessage = "Domain: \(error.domain)\nCode: \(error.code)"
            let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
            let actionTitle = NSLocalizedString("global.alert.ok", comment: "title to confirm alert")
            alert.addAction(UIAlertAction(title: actionTitle, style: .default) { _ in
                alert.dismiss(animated: trueUnlessReduceMotionEnabled)
            })

            AppDelegate.instance().tabBarController?.present(alert, animated: trueUnlessReduceMotionEnabled)
        }
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
