//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

// swiftlint:disable type_body_length file_length

import Common
import CoreData

protocol Persistable {

    static var identifierKeyPath: WritableKeyPath<Self, String> { get }

}

protocol PersistenceManagerConfiguration {

    associatedtype Resource: NSManagedObject & Persistable
    associatedtype Session: URLSession

    static var keyPath: ReferenceWritableKeyPath<Resource, NSData?> { get }
    static var downloadType: String { get }
    static var titleForFailedDownloadAlert: String { get }

    static func newFetchRequest() -> NSFetchRequest<Resource>

}

class PersistenceManager<Configuration>: NSObject where Configuration: PersistenceManagerConfiguration {

    typealias Resource = Configuration.Resource
    typealias Session = Configuration.Session

    lazy var session: Session = self.newDownloadSession()

    lazy var persistentContainerQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()

    var activeDownloads: [URLSessionTask: String] = [:]
    var progresses: [String: Double] = [:]
    var didRestorePersistenceManager = false

    override init() {
        super.init()
        self.startListeningToDownloadProgressChanges()
    }

    // swiftlint:disable:next unavailable_function
    func fileSize(for resource: Resource) -> UInt64? {
        fatalError("You have to implement this in a subclass")
    }

    // swiftlint:disable:next unavailable_function
    func newDownloadSession() -> Session {
        fatalError("You have to implement this in a subclass")
    }

    // swiftlint:disable:next unavailable_function
    func downloadTask(with url: URL, for resource: Resource, on session: Session) -> URLSessionTask? {
        fatalError("You have to implement this in a subclass")
    }

    // MARK: functionality

    func startListeningToDownloadProgressChanges() {
        // swiftlint:disable:next discarded_notification_center_observer
        NotificationCenter.default.addObserver(forName: DownloadProgress.didChangeNotification, object: nil, queue: nil) { notification in
            guard notification.userInfo?[DownloadNotificationKey.downloadType] as? String == Configuration.downloadType,
                let resourceId = notification.userInfo?[DownloadNotificationKey.resourceId] as? String,
                let progress = notification.userInfo?[DownloadNotificationKey.downloadProgress] as? Double else { return }

            self.progresses[resourceId] = progress
        }
    }

    func createPersistenceContainerQueue() -> OperationQueue {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }

    func restoreDownloads() {
        guard !self.didRestorePersistenceManager else { return }
        self.didRestorePersistenceManager = true

        self.session.getAllTasks { tasks in
            for task in tasks {
                guard let resourceId = task.taskDescription else { break }
                self.activeDownloads[task] = resourceId
            }
        }
    }

    func startDownload(with url: URL, for resource: Resource) {
        guard let task = self.downloadTask(with: url, for: resource, on: self.session) else {
            return
        }

        let resourceIdentifier = resource[keyPath: Resource.identifierKeyPath]
        task.taskDescription = resourceIdentifier
        self.activeDownloads[task] = resourceIdentifier

        task.resume()

        self.didStartDownload(for: resource)

        self.persistentContainerQueue.addOperation {
            let context = CoreDataHelper.persistentContainer.newBackgroundContext()
            context.performAndWait {
                self.resourceModificationAfterStartingDownload(for: resource)
                try? context.save()
            }

            var userInfo: [String: Any] = [:]
            userInfo[DownloadNotificationKey.downloadType] = Configuration.downloadType
            userInfo[DownloadNotificationKey.resourceId] = resourceIdentifier
            userInfo[DownloadNotificationKey.downloadState] = DownloadState.downloading.rawValue

            NotificationCenter.default.post(name: DownloadState.didChangeNotification, object: nil, userInfo: userInfo)
        }
    }

    func downloadState(for resource: Resource) -> DownloadState {
        if let localFileLocation = self.localFileLocation(for: resource), FileManager.default.fileExists(atPath: localFileLocation.path) {
            return .downloaded
        }

        let resourceIdentifier = resource[keyPath: Resource.identifierKeyPath]
        for (_, resourceId) in self.activeDownloads where resourceIdentifier == resourceId {
            return self.progresses[resourceId] != nil ? .downloading : .pending
        }

        return .notDownloaded
    }

    func downloadProgress(for resource: Resource) -> Double? {
        let resourceIdentifier = resource[keyPath: Resource.identifierKeyPath]
        return self.progresses[resourceIdentifier]
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

    private func deleteDownload(for resource: Resource, in context: NSManagedObjectContext) {
        guard let localFileLocation = self.localFileLocation(for: resource) else { return }

        let resourceIdentifier = resource[keyPath: Resource.identifierKeyPath]

        do {
            try FileManager.default.removeItem(at: localFileLocation)
            resource[keyPath: Configuration.keyPath] = nil
            self.resourceModificationAfterDeletingDownload(for: resource)
            try context.save()
        } catch {
            ErrorManager.shared.remember((Configuration.downloadType, resourceIdentifier), forKey: "resource")
            ErrorManager.shared.report(error)
            logger.error("An error occurred deleting the file: \(error)")
        }

        var userInfo: [String: Any] = [:]
        userInfo[DownloadNotificationKey.downloadType] = Configuration.downloadType
        userInfo[DownloadNotificationKey.resourceId] = resourceIdentifier
        userInfo[DownloadNotificationKey.downloadState] = DownloadState.notDownloaded.rawValue

        NotificationCenter.default.post(name: DownloadState.didChangeNotification, object: nil, userInfo: userInfo)
    }

    func cancelDownload(for resource: Resource) {
        let resourceIdentifier = resource[keyPath: Resource.identifierKeyPath]
        var task: URLSessionTask?

        for (downloadtask, resourceId) in self.activeDownloads where resourceIdentifier == resourceId {
            self.didCancelDownload(for: resource)
            task = downloadtask
            break
        }

        task?.cancel()
    }

    func prepareForDeletion(of resource: Resource) {
        switch self.downloadState(for: resource) {
        case .pending, .downloading:
            self.cancelDownload(for: resource)
        case .downloaded:
            self.deleteDownload(for: resource)
        default:
            break
        }
    }

    func localFileLocation(for resource: Resource) -> URL? {
        guard let bookmarkData = resource[keyPath: Configuration.keyPath] as Data? else {
            return nil
        }

        var bookmarkDataIsStale = false
        guard let url = try? URL(resolvingBookmarkData: bookmarkData, bookmarkDataIsStale: &bookmarkDataIsStale) else {
            return nil
        }

        if bookmarkDataIsStale {
            return nil
        }

        return url
    }

    func formattedFileSize(for resource: Resource) -> String? {
        guard let sizeInBytes = self.fileSize(for: resource) else { return nil }
        return ByteCountFormatter.string(fromByteCount: Int64(sizeInBytes), countStyle: .file)
    }

    // MARK: callbacks

    // swiftlint:disable:next function_body_length
    func didCompleteDownloadTask(_ task: URLSessionTask, with error: Error?) {
        guard let resourceId = self.activeDownloads.removeValue(forKey: task) else { return }

        self.progresses.removeValue(forKey: resourceId)

        var userInfo: [String: Any] = [:]
        userInfo[DownloadNotificationKey.downloadType] = Configuration.downloadType
        userInfo[DownloadNotificationKey.resourceId] = resourceId

        self.persistentContainerQueue.addOperation {
            let context = CoreDataHelper.persistentContainer.newBackgroundContext()
            context.performAndWait {
                if let error = error as NSError? {
                    userInfo[DownloadNotificationKey.downloadState] = DownloadState.notDownloaded.rawValue

                    let fetchRequest = Configuration.newFetchRequest()
                    fetchRequest.predicate = NSPredicate(format: "id == %@", resourceId)
                    fetchRequest.fetchLimit = 1

                    switch context.fetchSingle(fetchRequest) {
                    case let .success(resource):
                        if let localFileLocation = self.localFileLocation(for: resource) {
                            do {
                                try FileManager.default.removeItem(at: localFileLocation)
                                resource[keyPath: Configuration.keyPath] = nil
                                self.resourceModificationAfterDeletingDownload(for: resource)
                                try context.save()
                            } catch {
                                ErrorManager.shared.remember((Configuration.downloadType, resourceId), forKey: "resource")
                                ErrorManager.shared.report(error)
                                logger.error("An error occurred deleting the file: \(error)")
                            }
                        }

                        self.didFailToDownloadResource(resource, with: error)
                    case let .failure(error):
                        ErrorManager.shared.remember((Configuration.downloadType, resourceId), forKey: "resource")
                        ErrorManager.shared.report(error)
                        logger.error("Failed to complete download for '\(Configuration.downloadType)' resource '\(resourceId)': \(error)")
                    }
                } else {
                    let started = self.startSupplementaryDownloads(for: task, with: resourceId)

                    if started {
                        userInfo[DownloadNotificationKey.downloadState] = DownloadState.downloading.rawValue
                    } else {
                        userInfo[DownloadNotificationKey.downloadState] = DownloadState.downloaded.rawValue

                        let fetchRequest = Configuration.newFetchRequest()
                        fetchRequest.predicate = NSPredicate(format: "id == %@", resourceId)
                        fetchRequest.fetchLimit = 1

                        if let resource = context.fetchSingle(fetchRequest).value {
                            self.didFinishDownload(for: resource)
                        }
                    }
                }

                NotificationCenter.default.post(name: DownloadState.didChangeNotification, object: nil, userInfo: userInfo)
            }
        }
    }

    func didFinishDownloadTask(_ task: URLSessionTask, to location: URL) {
        guard let resourceId = self.activeDownloads[task] else { return }

        let context = CoreDataHelper.persistentContainer.newBackgroundContext()
        context.performAndWait {
            let fetchRequest = Configuration.newFetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", resourceId)
            fetchRequest.fetchLimit = 1

            switch context.fetchSingle(fetchRequest) {
            case let .success(resource):
                do {
                    let bookmark = try location.bookmarkData()
                    resource[keyPath: Configuration.keyPath] = NSData(data: bookmark)
                    try context.save()
                    logger.debug("Successfully downloaded file for '\(Configuration.downloadType)' resource '\(resourceId)'")
                } catch {
                    logger.debug("Failed to downloaded file for '\(Configuration.downloadType)' resource '\(resourceId)'")
                    self.deleteDownload(for: resource, in: context)
                }
            case let .failure(error):
                ErrorManager.shared.remember((Configuration.downloadType, resourceId), forKey: "resource")
                ErrorManager.shared.report(error)
                logger.error("Failed to finish download for '\(Configuration.downloadType)' resource '\(resourceId)': \(error)")
            }
        }
    }

    func didFailToDownloadResource(_ resource: Resource, with error: NSError) {
        let resourceId = resource[keyPath: Resource.identifierKeyPath]

        if error.domain == NSURLErrorDomain && error.code == NSURLErrorCancelled {
            logger.debug("Canceled download of resource (type: \(Resource.self) id: \(resourceId))")
            return
        }

        ErrorManager.shared.remember((Resource.self, resourceId), forKey: "resource")
        ErrorManager.shared.report(error)
        logger.error("""
            Unknown asset download error - \
            resource type: \(Resource.self) | \
            resource id: \(resourceId) | \
            domain: \(error.domain) | \
            code: \(error.code)
            """)

        // show error
        DispatchQueue.main.async {
            let alertTitle = Configuration.titleForFailedDownloadAlert
            let alertMessage = "Domain: \(error.domain)\nCode: \(error.code)"
            let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
            let actionTitle = NSLocalizedString("global.alert.ok", comment: "title to confirm alert")
            alert.addAction(UIAlertAction(title: actionTitle, style: .default) { _ in
                alert.dismiss(animated: trueUnlessReduceMotionEnabled)
            })

            let rootViewController: UIViewController? = {
                if #available(iOS 13, *) {
                    let activeScene = UIApplication.shared.connectedScenes.first { $0.activationState == .foregroundActive }
                    if let sceneDelegate = activeScene?.delegate as? SceneDelegate {
                        return sceneDelegate.window?.rootViewController
                    } else if let sceneDelegate = activeScene?.delegate as? CourseSceneDelegate {
                        return sceneDelegate.window?.rootViewController
                    } else {
                        return nil
                    }
                } else {
                    let appDelegate = UIApplication.shared.delegate as? AppDelegate
                    return appDelegate?.window?.rootViewController
                }
            }()

            let presentingViewController = rootViewController?.presentedViewController ?? rootViewController
            presentingViewController?.present(alert, animated: trueUnlessReduceMotionEnabled)
        }
    }

    // MARK: configurations

    func startSupplementaryDownloads(for task: URLSessionTask, with resourceIdentifier: String) -> Bool { return false }
    func resourceModificationAfterStartingDownload(for resource: Resource) {}
    func resourceModificationAfterDeletingDownload(for resource: Resource) {}

    // MARK: delegate methods

    func didStartDownload(for resource: Resource) {}
    func didCancelDownload(for resource: Resource) {}
    func didFinishDownload(for resource: Resource) {}

}

extension PersistenceManager {

    static var systemFreeSize: UInt64 {
        return self.deviceData(for: .systemFreeSize) ?? 0
    }

    static var systemSize: UInt64 {
        return self.deviceData(for: .systemSize) ?? 0
    }

    private static func deviceData(for key: FileAttributeKey) -> UInt64? {
        guard let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last else {
            return nil
        }

        guard let deviceData = try? FileManager.default.attributesOfFileSystem(forPath: path) else {
            return nil
        }

        guard let value = deviceData[key] as? NSNumber else {
            return nil
        }

        return value.uint64Value
    }

}
