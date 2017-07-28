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

    fileprivate var activeDownloadsMap: [AVAssetDownloadTask: String] = [:]

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
                guard let assetDownloadTask = task as? AVAssetDownloadTask, let assetId = task.taskDescription else { break }

                self.activeDownloadsMap[assetDownloadTask] = assetId
            }
        }
    }

    func downloadStream(for video: Video) {
        guard let url = video.hlsURL else {
            return
        }
        
        let assertTitle = video.item?.title ?? "Untitled video"
        
        var posterImageData: Data?
        if let urlString = video.single_stream_thumbnail_url, let posterImageURL = URL(string: urlString) {
            do {
                posterImageData = try Data(contentsOf: posterImageURL)
            } catch {
                print("Failed to load poster image")
            }
        }
        guard let task = self.assetDownloadURLSession.makeAssetDownloadTask(asset: AVURLAsset(url: url), assetTitle: assertTitle, assetArtworkData: posterImageData, options: [AVAssetDownloadTaskMinimumRequiredMediaBitrateKey: 265000]) else { return }

        task.taskDescription = video.id

        self.activeDownloadsMap[task] = video.id

        task.resume()

        video.download_date = Date()
        do {
            try video.managedObjectContext?.save()
        } catch {
            print("Failed to update download progress")
        }
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
            if video.id == assetIdentifier {
                return .downloading
            }
        }

        return .notDownloaded
    }

    func deleteAsset(forVideo video: Video) {
        if let localfileLocation = self.localAssetFor(video: video)?.url {
            do {
                try FileManager.default.removeItem(at: localfileLocation)

                video.download_date = nil
                video.local_file_bookmark = nil
                try video.managedObjectContext?.save()
            } catch {
                print("An error occured deleting the file: \(error)")
            }
        }
    }

    func cancelDownload(forVideo video: Video) {
        var task: AVAssetDownloadTask?

        for (taskKey, assetVal) in activeDownloadsMap {
            if video.id == assetVal  {
                task = taskKey
                break
            }
        }

        task?.cancel()
    }


}

extension VideoPersistenceManager: AVAssetDownloadDelegate {

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let task = task as? AVAssetDownloadTask, let asset = self.activeDownloadsMap.removeValue(forKey: task) else { return }

        if let error = error as NSError? {
            // TODO: delete local file if present
            print(error)
        } else {
            // TODO: set asset as download state
            print(asset)
        }
    }

    private func fetchVideo(withIdentifier videoId: String) -> Video? {
        let request: NSFetchRequest<Video> = Video.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", videoId)
        request.fetchLimit = 1
        do {
            return try CoreDataHelper.executeFetchRequest(request).first
        } catch {
            return nil
        }
    }

    private func videoFor(assetDownloadTask task: AVAssetDownloadTask) -> Video? {
        if let videoId = self.activeDownloadsMap[task], let video = self.fetchVideo(withIdentifier: videoId) {
            return video
        }
        return nil
    }

    func urlSession(_ session: URLSession, assetDownloadTask: AVAssetDownloadTask, didFinishDownloadingTo location: URL) {
        if let video = self.videoFor(assetDownloadTask: assetDownloadTask) {
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
        guard let video = self.videoFor(assetDownloadTask: assetDownloadTask) else { return }

        var percentComplete = 0.0
        for value in loadedTimeRanges {
            let loadedTimeRange: CMTimeRange = value.timeRangeValue
            percentComplete += CMTimeGetSeconds(loadedTimeRange.duration) / CMTimeGetSeconds(timeRangeExpectedToLoad.duration)
        }

        // TODO update progress
    }

}
