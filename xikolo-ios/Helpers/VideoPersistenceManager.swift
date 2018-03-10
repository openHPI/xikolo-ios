//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import AVFoundation
import CoreData
import Foundation
import UIKit

class VideoPersistenceManager: NSObject {

    static let shared = VideoPersistenceManager()

    private var assetDownloadURLSession: AVAssetDownloadURLSession!
    private var activeDownloadsMap: [AVAssetDownloadTask: String] = [:]
    private var progressMap: [String: Double] = [:]
    private let persistentContainerQueue: OperationQueue = {
        let queue = OperationQueue();
        queue.maxConcurrentOperationCount = 1;
        return queue;
    }()

    private var didRestorePersistenceManager = false

    override private init() {
        super.init()
        let sessionIdentifier = "\(Brand.AppID).asset-download"
        let backgroundConfiguration = URLSessionConfiguration.background(withIdentifier: sessionIdentifier)
        self.assetDownloadURLSession = AVAssetDownloadURLSession(configuration: backgroundConfiguration,
                                                                 assetDownloadDelegate: self,
                                                                 delegateQueue: OperationQueue.main)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleAssetDownloadProgressNotification(_:)),
                                               name: NotificationKeys.VideoDownloadStateChangedKey,
                                               object: nil)
    }

    func restorePersistenceManager() {
        guard !self.didRestorePersistenceManager else { return }

        self.didRestorePersistenceManager = true

        self.assetDownloadURLSession.getAllTasks { tasks in
            for task in tasks {
                guard let assetDownloadTask = task as? AVAssetDownloadTask, let videoId = task.taskDescription else { break }
                self.activeDownloadsMap[assetDownloadTask] = videoId
            }
        }
    }

    func downloadStream(for video: Video) {
        guard let url = video.singleStream?.hlsURL else { return }

        let assetTitleCourse = video.item?.section?.course?.slug ?? "Unknown course"
        let assetTitleItem = video.item?.title ?? "Untitled video"
        let assetTitle = "\(assetTitleItem) (\(assetTitleCourse))".safeAsciiString() ?? "Untitled video"
        let options = [AVAssetDownloadTaskMinimumRequiredMediaBitrateKey: UserDefaults.standard.videoQualityForDownload.rawValue]

        guard let task = self.assetDownloadURLSession.makeAssetDownloadTask(asset: AVURLAsset(url: url),
                                                                            assetTitle: assetTitle,
                                                                            assetArtworkData: video.posterImageData,
                                                                            options: options) else { return }
        TrackingHelper.createEvent(.videoDownloadStart, resourceType: .video, resourceId: video.id)
        task.taskDescription = video.id

        self.activeDownloadsMap[task] = video.id

        task.resume()

        self.persistentContainerQueue.addOperation {
            let context = CoreDataHelper.persistentContainer.newBackgroundContext()
            context.performAndWait {
                video.downloadDate = Date()
                do {
                    try context.save()
                } catch {
                    CrashlyticsHelper.shared.setObjectValue(video.id, forKey: "video_id")
                    CrashlyticsHelper.shared.recordError(error)
                    log.error("Failed to save video (start)")
                }
            }

            var userInfo: [String: Any] = [:]
            userInfo[Video.Keys.id] = video.id
            userInfo[Video.Keys.downloadState] = Video.DownloadState.downloading.rawValue

            NotificationCenter.default.post(name: NotificationKeys.VideoDownloadStateChangedKey, object: nil, userInfo: userInfo)
        }

    }

    func localAsset(for video: Video) -> AVURLAsset? {
        guard let localFileLocation = video.localFileBookmark as Data? else { return nil }

        var asset: AVURLAsset?
        var bookmarkDataIsStale = false
        do {
            guard let url = try URL(resolvingBookmarkData: localFileLocation, bookmarkDataIsStale: &bookmarkDataIsStale) else {
                return nil
            }

            if bookmarkDataIsStale {
                return nil
            }

            asset = AVURLAsset(url: url)

            return asset
        } catch {
            return nil
        }
    }

    func downloadState(for video: Video) -> Video.DownloadState {
        if let localFileLocation = self.localAsset(for: video)?.url {
            if FileManager.default.fileExists(atPath: localFileLocation.path) {
                return .downloaded
            }
        }

        for (_, downloadingVideoId) in self.activeDownloadsMap {
            if video.id == downloadingVideoId {
                if self.progressMap[video.id] != nil {
                    return .downloading
                }
                return .pending
            }
        }

        return .notDownloaded
    }

    func progress(for video: Video) -> Double? {
        return self.progressMap[video.id]
    }

    func deleteAsset(for video: Video) {
        let objectId = video.objectID
        self.persistentContainerQueue.addOperation {
            let context = CoreDataHelper.persistentContainer.newBackgroundContext()
            context.performAndWait {
                guard let video = context.existingTypedObject(with: objectId) as? Video else {
                    return
                }
                self.deleteAsset(for: video, in: context)
            }
        }
    }

    private func deleteAsset(for video: Video, in context: NSManagedObjectContext) {
        guard let localFileLocation = self.localAsset(for: video)?.url else { return }

        do {
            try FileManager.default.removeItem(at: localFileLocation)
            video.downloadDate = nil
            video.localFileBookmark = nil
            try context.save()
        } catch {
            CrashlyticsHelper.shared.setObjectValue(video.id, forKey: "video_id")
            CrashlyticsHelper.shared.recordError(error)
            log.error("An error occured deleting the file: \(error)")
        }

        var userInfo: [String: Any] = [:]
        userInfo[Video.Keys.id] = video.id
        userInfo[Video.Keys.downloadState] = Video.DownloadState.notDownloaded.rawValue

        NotificationCenter.default.post(name: NotificationKeys.VideoDownloadStateChangedKey, object: nil, userInfo: userInfo)
    }


    func cancelDownload(for video: Video) {
        var task: AVAssetDownloadTask?

        for (donwloadTask, downloadingVideoId) in activeDownloadsMap {
            if video.id == downloadingVideoId  {
                TrackingHelper.createEvent(.videoDownloadCanceled, resourceType: .video, resourceId: video.id)
                task = donwloadTask
                break
            }
        }

        task?.cancel()
    }

    @objc func handleAssetDownloadProgressNotification(_ notification: Notification) {
        guard let videoId = notification.userInfo?[Video.Keys.id] as? String,
            let progress = notification.userInfo?[Video.Keys.precentDownload] as? Double else { return }

        self.progressMap[videoId] = progress
    }

}

extension VideoPersistenceManager: AVAssetDownloadDelegate {

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let task = task as? AVAssetDownloadTask, let videoId = self.activeDownloadsMap.removeValue(forKey: task) else { return }

        self.progressMap.removeValue(forKey: videoId)

        var userInfo: [String: Any] = [:]
        userInfo[Video.Keys.id] = videoId

        self.persistentContainerQueue.addOperation {
            let context = CoreDataHelper.persistentContainer.newBackgroundContext()
            context.performAndWait {
                if let error = error as NSError? {
                    let fetchRequest = VideoHelper.FetchRequest.video(withId: videoId)
                    switch context.fetchSingle(fetchRequest) {
                    case .success(let video):
                        if let localFileLocation = self.localAsset(for: video)?.url {
                            do {
                                try FileManager.default.removeItem(at: localFileLocation)
                                video.downloadDate = nil
                                video.localFileBookmark = nil
                                try context.save()
                            } catch {
                                CrashlyticsHelper.shared.setObjectValue(videoId, forKey: "video_id")
                                CrashlyticsHelper.shared.recordError(error)
                                log.error("An error occured deleting the file: \(error)")
                            }
                        }

                        if error.domain == NSURLErrorDomain && error.code == NSURLErrorCancelled {
                            log.debug("Canceled download of video (video id: \(videoId))")
                        } else {
                            CrashlyticsHelper.shared.setObjectValue(videoId, forKey: "video_id")
                            CrashlyticsHelper.shared.recordError(error)
                            log.error("Unknown asset download error (video id: \(videoId) | domain: \(error.domain) | code: \(error.code)")

                            // show error
                            DispatchQueue.main.async {
                                let alertTitle = NSLocalizedString("course-item.video-download-alert.download-error.title", comment: "title to download error alert")
                                let alertMessage = "Domain: \(error.domain)\nCode: \(error.code)"
                                let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
                                let actionTitle = NSLocalizedString("global.alert.ok", comment: "title to confirm alert")
                                alert.addAction(UIAlertAction(title: actionTitle, style: .default) { _ in
                                    alert.dismiss(animated: true)
                                })
                                AppDelegate.instance().tabBarController?.present(alert, animated: true)
                            }
                        }

                        userInfo[Video.Keys.downloadState] = Video.DownloadState.notDownloaded.rawValue
                    case .failure(let error):
                        CrashlyticsHelper.shared.setObjectValue(videoId, forKey: "video_id")
                        CrashlyticsHelper.shared.recordError(error)
                        log.error("Failed to complete download for video \(videoId) : \(error)")
                    }
                } else {
                    userInfo[Video.Keys.downloadState] = Video.DownloadState.downloaded.rawValue
                    let context = ["video_download_pref": String(describing: UserDefaults.standard.videoQualityForDownload.rawValue)]
                    TrackingHelper.createEvent(.videoDownloadFinished, resourceType: .video, resourceId: videoId, context: context)
                }

                NotificationCenter.default.post(name: NotificationKeys.VideoDownloadStateChangedKey, object: nil, userInfo: userInfo)
            }
        }
    }

    func urlSession(_ session: URLSession, assetDownloadTask: AVAssetDownloadTask, didFinishDownloadingTo location: URL) {
        guard let videoId = self.activeDownloadsMap[assetDownloadTask] else { return }

        let context = CoreDataHelper.persistentContainer.newBackgroundContext()
        context.performAndWait {
            let fetchRequest = VideoHelper.FetchRequest.video(withId: videoId)
            switch context.fetchSingle(fetchRequest) {
            case .success(let video):
                do {
                    let bookmark = try location.bookmarkData()
                    video.localFileBookmark = NSData(data: bookmark)
                    try context.save()
                } catch {
                    // Failed to create bookmark for location
                    self.deleteAsset(for: video, in: context)
                }
            case .failure(let error):
                CrashlyticsHelper.shared.setObjectValue(videoId, forKey: "video_id")
                CrashlyticsHelper.shared.recordError(error)
                log.error("Failed to finish download for video \(videoId) : \(error)")
            }
        }

    }

    func urlSession(_ session: URLSession, assetDownloadTask: AVAssetDownloadTask, didLoad timeRange: CMTimeRange, totalTimeRangesLoaded loadedTimeRanges: [NSValue], timeRangeExpectedToLoad: CMTimeRange) {
        guard let videoId = self.activeDownloadsMap[assetDownloadTask] else { return }

        var percentComplete = 0.0
        for value in loadedTimeRanges {
            let loadedTimeRange: CMTimeRange = value.timeRangeValue
            percentComplete += CMTimeGetSeconds(loadedTimeRange.duration) / CMTimeGetSeconds(timeRangeExpectedToLoad.duration)
        }

        var userInfo: [String: Any] = [:]
        userInfo[Video.Keys.id] = videoId
        userInfo[Video.Keys.precentDownload] = percentComplete

        NotificationCenter.default.post(name: NotificationKeys.VideoDownloadProgressKey, object: nil, userInfo: userInfo)
    }

}
