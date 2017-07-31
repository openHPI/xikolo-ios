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

    override private init() {
        super.init()
        let sessionIdentifier = "\(Brand.AppID).asset-download"
        let backgroundConfiguration = URLSessionConfiguration.background(withIdentifier: sessionIdentifier)
        self.assetDownloadURLSession = AVAssetDownloadURLSession(configuration: backgroundConfiguration,
                                                                 assetDownloadDelegate: self,
                                                                 delegateQueue: OperationQueue.main)
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

        let assetTitleCourse = video.item?.section?.course?.slug ?? "Unknown course"
        let assetTitleItem = video.item?.title ?? "Untitled video"
        let assetTitle = "\(assetTitleItem) (\(assetTitleCourse))"

        guard let task = self.assetDownloadURLSession.makeAssetDownloadTask(asset: AVURLAsset(url: url),
                                                                            assetTitle: assetTitle,
                                                                            assetArtworkData: video.posterImageData,
                                                                            options: [AVAssetDownloadTaskMinimumRequiredMediaBitrateKey: 265000]) else { return }

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

    func localAssetFor(video: Video) -> AVURLAsset? {
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
        if let localFileLocation = self.localAssetFor(video: video)?.url {
            if FileManager.default.fileExists(atPath: localFileLocation.path) {
                return .downloaded
            }
        }

        for (_, assetIdentifier) in self.activeDownloadsMap {
            if video == assetIdentifier {
                return .downloading
            }
        }

        return .notDownloaded
    }

    func deleteAsset(forVideo video: Video) {
        if let localFileLocation = self.localAssetFor(video: video)?.url {
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

    func cancelDownload(forVideo video: Video) {
        var task: AVAssetDownloadTask?

        for (taskKey, assetVal) in activeDownloadsMap {
            if video == assetVal  {
                task = taskKey
                break
            }
        }

        task?.cancel()
    }

}

extension VideoPersistenceManager: AVAssetDownloadDelegate {

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let task = task as? AVAssetDownloadTask, let video = self.activeDownloadsMap.removeValue(forKey: task) else { return }

        var userInfo: [String: Any] = [:]
        userInfo[Video.Keys.id] = video.id

        if let error = error as NSError? {
            switch (error.domain, error.code) {
            case (NSURLErrorDomain, NSURLErrorCancelled):

                guard let localFileLocation = self.localAssetFor(video: video)?.url else { return }

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
                self.deleteAsset(forVideo: video)
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
