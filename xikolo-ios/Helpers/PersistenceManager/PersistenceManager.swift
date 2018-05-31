//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation

protocol PersistenceManager: AnyObject {

    associatedtype Resource : Pullable
    associatedtype Session : URLSession

    static var shared: Self { get }

    var persistentContainerQueue: OperationQueue { get }
    var session: Session { get }
    var keyPath: KeyPath<Resource, NSData?> { get }

    var activeDownloads: [URLSessionTask: String] { get set }
    var progresses: [String: Double] { get set }
    var didRestorePersistenceManager: Bool { get set }

    func restoreDownloads()
    func startDownload(with url: URL, for resource: Resource)
    func downloadState(for resource: Resource) -> DownloadState
    func downloadProgress(for resource: Resource) -> Double?
    func deleteDownload(for resource: Resource)
    func cancelDownload(for resource: Resource)

    func modifyLocalFileLocation(url: URL?) -> URL? // XXX
    func downloadTask(with url: URL, for resource: Resource, on session: Session) -> URLSessionTask?

}

extension PersistenceManager {

    func createPersistenceContainerQueue() -> OperationQueue {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }

    func restoreDownloads() {
        guard !self.didRestorePersistenceManager else { return }
        self.didRestorePersistenceManager = true

        self.session.getAllTasks { tasks in
            for task in tasks{
                guard let resourceId = task.taskDescription else { break }
                self.activeDownloads[task] = resourceId
            }
        }
    }

    func resolveBookmarkLocation(for resource: Resource) -> URL? {
        guard let bookmarkData = resource[keyPath: self.keyPath] as Data? else {
            return nil
        }

        var bookmarkDataIsStale = false
        guard let url = try? URL(resolvingBookmarkData: bookmarkData, bookmarkDataIsStale: &bookmarkDataIsStale) ?? nil else {
            return nil
        }

        if bookmarkDataIsStale {
            return nil
        }

        return self.modifyLocalFileLocation(url: url)
    }

    func modifyLocalFileLocation(url: URL?) -> URL? {
        return url
    }

    func startDownload(with url: URL, for resource: Resource) {
        guard let task = self.downloadTask(with: url, for: resource, on: self.session) else {
            return
        }

        task.taskDescription = resource.id
        self.activeDownloads[task] = resource.id

        task.resume()
    }

    func downloadState(for resource: Resource) -> DownloadState {
        if let bookmarkLocation = self.resolveBookmarkLocation(for: resource), FileManager.default.fileExists(atPath: bookmarkLocation.path) {
            return .downloaded
        }

        for (_, resourceId) in self.activeDownloads where resource.id == resourceId {
            return self.progresses[resourceId] != nil ? .downloading : .pending
        }

        return .notDownloaded
    }

    func downloadProgress(for resource: Resource) -> Double? {
        return self.progresses[resource.id]
    }

    func deleteDownload(for resource: Resource) {}

    func cancelDownload(for resource: Resource) {
        var task: URLSessionTask?

        for (downloadtask, resourceId) in self.activeDownloads where resource.id == resourceId {
            task = downloadtask
            break
        }

        task?.cancel()
    }

}
