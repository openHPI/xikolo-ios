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
                                               selector: #selector(VideoPersistenceManager.handleAssetDownloadProgressNotification(_:)),
                                               name: NotificationKeys.VideoDownloadStateChangedKey,
                                               object: nil)
    }

    func restorePersistenceManager() {
        guard !self.didRestorePersistenceManager else { return }

        self.didRestorePersistenceManager = true

        self.assetDownloadURLSession.getAllTasks { tasks in
            for task in tasks {
                guard let assetDownloadTask = task as? AVAssetDownloadTask, let videoId = task.taskDescription else { break }

                let request: NSFetchRequest<Video> = Video.fetchRequest()
                request.predicate = NSPredicate(format: "id == %@", videoId)
                request.fetchLimit = 1
                do {
                    let video = try CoreDataHelper.executeFetchRequest(request).first
                    self.activeDownloadsMap[assetDownloadTask] = video
                } catch {
                    print("Failed to restore download for video \(videoId)")
                }
            }
        }
    }

    func downloadStream(for video: Video) {
        guard let url = video.hlsURL else {
            return
        }

        if url.host == "player.vimeo.com" {
            // !!! Important !!!
            // When trying to download HLS videos, vimeo redirects to one of its CDN servers. The AVURLAssetDownload
            // can not handle such a redirect, which will result in a local video file that is not offline playable.
            // Therefore, we need to retrieve the redirect url before starting the video download.
            NetworkHelper.resolvedRedirectURL(for: url).onSuccess { redirectUrl in
                self.startDownload(of: video, withURL: redirectUrl)
            }.onFailure { _ in
                print("Failed to resolve redirect url")
            }
        } else {
            self.startDownload(of: video, withURL: url)
        }
    }

    private func startDownload(of video: Video, withURL url: URL) {
        let assetTitleCourse = video.item?.section?.course?.slug ?? "Unknown course"
        let assetTitleItem = video.item?.title ?? "Untitled video"
        let assetTitle = "\(assetTitleItem) (\(assetTitleCourse))"

        guard let task = self.assetDownloadURLSession.makeAssetDownloadTask(asset: AVURLAsset(url: url),
                                                                            assetTitle: assetTitle,
                                                                            assetArtworkData: video.posterImageData,
                                                                            options: [AVAssetDownloadTaskMinimumRequiredMediaBitrateKey: 750000]) else { return }

        task.taskDescription = video.id

        self.activeDownloadsMap[task] = video

        task.resume()

        video.download_date = Date()
        do {
            try video.managedObjectContext?.save()
        } catch {
            print("failed to save video (start)")
        }

        var userInfo: [String: Any] = [:]
        userInfo[Video.Keys.id] = video.id
        userInfo[Video.Keys.downloadState] = Video.DownloadState.downloading.rawValue

        NotificationCenter.default.post(name: NotificationKeys.VideoDownloadStateChangedKey, object: nil, userInfo: userInfo)
    }

    func localAsset(for video: Video) -> AVURLAsset? {
        guard let localFileLocation = video.local_file_bookmark as Data? else { return nil }

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
        if let localFileLocation = self.localAsset(for: video)?.url {
            do {
                try FileManager.default.removeItem(at: localFileLocation)

                video.download_date = nil
                video.local_file_bookmark = nil
                try video.managedObjectContext?.save()

                var userInfo: [String: Any] = [:]
                userInfo[Video.Keys.id] = video.id
                userInfo[Video.Keys.downloadState] = Video.DownloadState.notDownloaded.rawValue

                NotificationCenter.default.post(name: NotificationKeys.VideoDownloadStateChangedKey, object: nil, userInfo: userInfo)
            } catch {
                print("An error occured deleting the file: \(error)")
            }
        }
    }

    func cancelDownload(for video: Video) {
        var task: AVAssetDownloadTask?

        for (taskKey, assetVal) in activeDownloadsMap {
            if video == assetVal  {
                task = taskKey
                break
            }
        }

        task?.cancel()
    }

    func handleAssetDownloadProgressNotification(_ noticaition: Notification) {
        guard let videoId = noticaition.userInfo?[Video.Keys.id] as? String,
            let progress = noticaition.userInfo?[Video.Keys.precentDownload] as? Double else { return }

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
            switch (error.domain, error.code) {
            case (NSURLErrorDomain, NSURLErrorCancelled):

                guard let localFileLocation = self.localAsset(for: video)?.url else { return }

                do {
                    try FileManager.default.removeItem(at: localFileLocation)

                    video.download_date = nil
                    video.local_file_bookmark = nil
                    try video.managedObjectContext?.save()
                } catch {
                    print("An error occured deleting the file: \(error)")
                }

                userInfo[Video.Keys.downloadState] = Video.DownloadState.notDownloaded.rawValue
            case (NSURLErrorDomain, NSURLErrorUnknown):
                fatalError("Downloading HLS streams is not supported in the simulator.")
                // TODO better catch
            default:
                fatalError("An unexpected error occured \(error.domain)")

            }
        } else {
            userInfo[Video.Keys.downloadState] = Video.DownloadState.downloaded.rawValue
        }

        NotificationCenter.default.post(name: NotificationKeys.VideoDownloadStateChangedKey, object: nil, userInfo: userInfo)
    }

    func urlSession(_ session: URLSession, assetDownloadTask: AVAssetDownloadTask, didFinishDownloadingTo location: URL) {
        if let video = self.activeDownloadsMap[assetDownloadTask]  {
            do {
                let bookmark = try location.bookmarkData()
                video.local_file_bookmark = NSData(data: bookmark)
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
