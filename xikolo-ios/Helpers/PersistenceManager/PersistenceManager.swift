//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation
import CoreData

protocol PersistenceManager: AnyObject {

    associatedtype Resource : NSManagedObject & Pullable
    associatedtype Session : URLSession

    static var shared: Self { get }

    var persistentContainerQueue: OperationQueue { get }
    var session: Session { get }
    var keyPath: ReferenceWritableKeyPath<Resource, NSData?> { get }

    var activeDownloads: [URLSessionTask: String] { get set }
    var progresses: [String: Double] { get set }
    var didRestorePersistenceManager: Bool { get set }

    func restoreDownloads()
    func startDownload(with url: URL, for resource: Resource)
    func downloadState(for resource: Resource) -> DownloadState
    func downloadProgress(for resource: Resource) -> Double?
    func deleteDownload(for resource: Resource)
    func cancelDownload(for resource: Resource)
    func localFileLocation(for resource: Resource) -> URL?

    func downloadTask(with url: URL, for resource: Resource, on session: Session) -> URLSessionTask?

    func resourceModificationAfterDeletingDownload(for resourse: Resource)

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

    func localFileLocation(for resource: Resource) -> URL? {
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
        if let localFileLocation = self.localFileLocation(for: resource), FileManager.default.fileExists(atPath: localFileLocation.path) {
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

    func deleteDownload(for resource: Resource) {
        let objectId = resource.objectID
        self.persistentContainerQueue.addOperation {
            let context = CoreDataHelper.persistentContainer.newBackgroundContext()
            context.performAndWait {
                guard let refreshedResource = context.existingTypedObject(with: objectId) as? Resource else { return }
                self.deleteDownload(for: refreshedResource, in: context)
            }
        }
    }

    func deleteDownload(for resource: Resource, in context: NSManagedObjectContext) {
        guard let localFileLocation = self.localFileLocation(for: resource) else { return }

        do {
            try FileManager.default.removeItem(at: localFileLocation)
            resource[keyPath: self.keyPath] = nil
            self.resourceModificationAfterDeletingDownload(for: resource)
            try context.save()
        } catch {
            CrashlyticsHelper.shared.setObjectValue(resource.id, forKey: "video_id")
            CrashlyticsHelper.shared.recordError(error)
            log.error("An error occured deleting the file: \(error)")
        }

        var userInfo: [String: Any] = [:]
        userInfo[Video.Keys.id] = resource.id
        userInfo[Video.Keys.downloadState] = DownloadState.notDownloaded.rawValue

        NotificationCenter.default.post(name: NotificationKeys.DownloadStateDidChange, object: nil, userInfo: userInfo)
    }

    func cancelDownload(for resource: Resource) {
        var task: URLSessionTask?

        for (downloadtask, resourceId) in self.activeDownloads where resource.id == resourceId {
            task = downloadtask
            break
        }

        task?.cancel()
    }

    func resourceModificationAfterDeletingDownload(for resource: Resource) {}

}
