//
//  VideoPersistenceManager.swift
//  xikolo-ios
//
//  Created by Max Bothe on 26/07/17.
//  Copyright © 2017 HPI. All rights reserved.
//

import Foundation
import AVFoundation
import CoreData
import UIKit

class VideoPersistenceManager: NSObject {

    static let shared = VideoPersistenceManager()

    private var didRestorePersistenceManager = false

    private var assetDownloadURLSession: AVAssetDownloadURLSession!

    fileprivate var activeDownloadsMap: [AVAssetDownloadTask: Video] = [:]
    fileprivate var progressMap: [String: Double] = [:]

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

                CoreDataHelper.persistentContainer.performBackgroundTask { context in
                    let fetchRequest = VideoHelper.FetchRequest.video(withId: videoId)
                    switch context.fetchSingle(fetchRequest) {
                    case .success(let video):
                        self.activeDownloadsMap[assetDownloadTask] = video
                    case .failure(let error):
                        log.error("Failed to restore download for video \(videoId) : \(error)")
                    }
                }
            }
        }
    }

    func downloadStream(for video: Video) {
        guard let url = video.singleStream?.hlsURL else { return }

        let assetTitleCourse = video.item?.section?.course?.slug ?? "Unknown course"
        let assetTitleItem = video.item?.title ?? "Untitled video"
        let assetTitle = "\(assetTitleItem) (\(assetTitleCourse))".safeAsciiString() ?? "Untitled video"
        let options = [AVAssetDownloadTaskMinimumRequiredMediaBitrateKey: UserDefaults.standard.videoPersistenceQuality.rawValue]

        guard let task = self.assetDownloadURLSession.makeAssetDownloadTask(asset: AVURLAsset(url: url),
                                                                            assetTitle: assetTitle,
                                                                            assetArtworkData: video.posterImageData,
                                                                            options: options) else { return }
        TrackingHelper.createEvent(.videoDownloadStart, resourceType: .video, resourceId: video.id)
        task.taskDescription = video.id

        self.activeDownloadsMap[task] = video

        task.resume()

        video.downloadDate = Date()
        do {
            try video.managedObjectContext?.save()
        } catch {
            log.error("Failed to save video (start)")
        }

        var userInfo: [String: Any] = [:]
        userInfo[Video.Keys.id] = video.id
        userInfo[Video.Keys.downloadState] = Video.DownloadState.downloading.rawValue

        NotificationCenter.default.post(name: NotificationKeys.VideoDownloadStateChangedKey, object: nil, userInfo: userInfo)
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

        for (_, assetIdentifier) in self.activeDownloadsMap {
            if video.id == assetIdentifier.id {
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
        guard let localFileLocation = self.localAsset(for: video)?.url else { return }

        do {
            try FileManager.default.removeItem(at: localFileLocation)
            video.downloadDate = nil
            video.localFileBookmark = nil
            try video.managedObjectContext?.save()
        } catch {
            log.error("An error occured deleting the file: \(error)")
        }

        var userInfo: [String: Any] = [:]
        userInfo[Video.Keys.id] = video.id
        userInfo[Video.Keys.downloadState] = Video.DownloadState.notDownloaded.rawValue

        NotificationCenter.default.post(name: NotificationKeys.VideoDownloadStateChangedKey, object: nil, userInfo: userInfo)
    }

    func cancelDownload(for video: Video) {
        var task: AVAssetDownloadTask?

        for (taskKey, assetVal) in activeDownloadsMap {
            if video == assetVal  {
                TrackingHelper.createEvent(.videoDownloadCanceled, resourceType: .video, resourceId: video.id)
                task = taskKey
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
        guard let task = task as? AVAssetDownloadTask, let video = self.activeDownloadsMap.removeValue(forKey: task) else { return }

        self.progressMap.removeValue(forKey: video.id)

        var userInfo: [String: Any] = [:]
        userInfo[Video.Keys.id] = video.id

        if let error = error as NSError? {
            if let localFileLocation = self.localAsset(for: video)?.url {
                do {
                    try FileManager.default.removeItem(at: localFileLocation)
                    video.downloadDate = nil
                    video.localFileBookmark = nil
                    try? video.managedObjectContext?.save()
                } catch {
                    log.error("An error occured deleting the file: \(error)")
                }
            }

            if error.domain == NSURLErrorDomain && error.code == NSURLErrorCancelled {
                log.debug("Canceled download of video (video id: \(video.id))")
            } else {
                log.error("Unknown asset download error (video id: \(video.id) | domain: \(error.domain) | code: \(error.code)")

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
        } else {
            userInfo[Video.Keys.downloadState] = Video.DownloadState.downloaded.rawValue
            let context = ["video_download_pref": String(describing: UserDefaults.standard.videoPersistenceQuality.rawValue)]
            TrackingHelper.createEvent(.videoDownloadFinished, resourceType: .video, resourceId: video.id, context: context)
        }

        NotificationCenter.default.post(name: NotificationKeys.VideoDownloadStateChangedKey, object: nil, userInfo: userInfo)
    }

    func urlSession(_ session: URLSession, assetDownloadTask: AVAssetDownloadTask, didFinishDownloadingTo location: URL) {
        if let video = self.activeDownloadsMap[assetDownloadTask]  {
            do {
                let bookmark = try location.bookmarkData()
                video.localFileBookmark = NSData(data: bookmark)
                try video.managedObjectContext?.save()
            } catch {
                // Failed to create bookmark for location
                self.deleteAsset(for: video)
            }
        }
    }

    func urlSession(_ session: URLSession, assetDownloadTask: AVAssetDownloadTask, didLoad timeRange: CMTimeRange, totalTimeRangesLoaded loadedTimeRanges: [NSValue], timeRangeExpectedToLoad: CMTimeRange) {
        guard let video = self.activeDownloadsMap[assetDownloadTask] else { return }

        var percentComplete = 0.0
        for value in loadedTimeRanges {
            let loadedTimeRange: CMTimeRange = value.timeRangeValue
            percentComplete += CMTimeGetSeconds(loadedTimeRange.duration) / CMTimeGetSeconds(timeRangeExpectedToLoad.duration)
        }

        var userInfo: [String: Any] = [:]
        userInfo[Video.Keys.id] = video.id
        userInfo[Video.Keys.precentDownload] = percentComplete

        NotificationCenter.default.post(name: NotificationKeys.VideoDownloadProgressKey, object: nil, userInfo: userInfo)
    }

}
