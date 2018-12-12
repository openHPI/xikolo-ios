//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures
import CoreData
import Foundation
import SyncEngine

public class SyncPushEngineManager {

    private let persistentContainerQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()

    let syncEngine: XikoloSyncEngine
    private var pushEngines: [SyncPushEngine] = []

    public init(syncEngine: XikoloSyncEngine) {
        self.syncEngine = syncEngine
    }

    public func startObserving() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(coreDataChange(note:)),
                                               name: NSNotification.Name.NSManagedObjectContextObjectsDidChange,
                                               object: CoreDataHelper.viewContext)
    }

    public func stopObserving() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: CoreDataHelper.viewContext)
    }

    public func register<Resource>(_ newType: Resource.Type) where Resource: NSManagedObject & Pushable {
        let pushEngine = SyncPushEnginePush(type: Resource.self, manager: self)
        self.pushEngines.append(pushEngine)
    }

    public func register<Resource>(_ newType: Resource.Type) where Resource: NSManagedObject & Pushable & Pullable {
        let pushEngine = SyncPushEnginePushPull(type: Resource.self, manager: self)
        self.pushEngines.append(pushEngine)
    }

    @objc private func coreDataChange(note: Notification) {
        let shouldCheckForChangesToPush = [NSUpdatedObjectsKey, NSInsertedObjectsKey, NSRefreshedObjectsKey].map { key in
            guard let objects = note.userInfo?[key] as? Set<NSManagedObject>, !objects.isEmpty else { return false }
            return objects.contains { $0 is Pushable }
        }.reduce(false) { $0 || $1 }

        if shouldCheckForChangesToPush {
            self.pushEngines.forEach { $0.check() }
        }

    }

    func addOperation(_ block: @escaping () -> Void) {
        self.persistentContainerQueue.addOperation(block)
    }

}

protocol SyncPushEngine {
    func check()
}

class SyncPushEnginePush<Resource>: SyncPushEngine where Resource: NSManagedObject & Pushable {

    private let resourceType: Resource.Type
    weak var manager: SyncPushEngineManager?

    init(type: Resource.Type, manager: SyncPushEngineManager) {
        self.resourceType = type
        self.manager = manager
    }

    func check() {
        guard let entityName = Resource.entity().name else {
            return
        }

        CoreDataHelper.persistentContainer.performBackgroundTask { context in
            let fetchRequest = NSFetchRequest(entityName: entityName) as NSFetchRequest<NSFetchRequestResult>

            do {
                let objects = try context.fetch(fetchRequest)
                for case let object as (NSManagedObject & Pushable) in objects {
                    self.pushChanges(for: object.objectID)
                }
            } catch {
                ErrorManager.shared.report(error)
            }
        }
    }

    private func pushChanges(for managedObjectId: NSManagedObjectID) {
        self.manager?.addOperation {
            let context = CoreDataHelper.persistentContainer.newBackgroundContext()
            context.performAndWait {
                guard let object = try? context.existingObject(with: managedObjectId), let resource = object as? Resource else {
                    log.info("Resource to be pushed could not be found")
                    return
                }

                guard resource.objectState != .unchanged else {
                    log.info("No change to be pushed for resource of type \(type(of: resource).type)")
                    return
                }

                var pushFuture: Future<Void, XikoloError>?

                if resource.objectState == .new {
                    pushFuture = self.manager?.syncEngine.createResource(resource)
                } else {
                    log.warning("unhandle resource modification")
                }

                // it makes only sense to retry on network errors
                pushFuture = pushFuture?.recoverWith { error -> Future<(), XikoloError> in
                    if case .network = error {
                        return Future(error: error)
                    } else if case let .synchronization(.api(.response(statusCode: statusCode, headers: _))) = error, 500 ... 599 ~= statusCode {
                        return Future(error: error)
                    }

                    log.error("Failed to push resource modification", error: error)
                    ErrorManager.shared.report(error)
                    return Future(value: ())
                }

                guard pushFuture?.forced().value != nil else {
                    log.warning("Failed to push resource modification due to network issues")
                    return
                }

                // post sync actions
                if resource.objectState == .deleted || !(resource is Pullable) {
                    context.delete(resource)
                    log.info("Deleted local resource of type: %@", type(of: resource).type)
                } else if resource.objectState == .new || resource.objectState == .modified {
                    resource.markAsUnchanged()
                }

                do {
                    try context.save()
                } catch {
                    log.error("while pushing core data changes: \(error)")
                    ErrorManager.shared.report(error)
                }
            }
        }
    }

}

class SyncPushEnginePushPull<Resource>: SyncPushEngine where Resource: NSManagedObject & Pushable & Pullable {

    private let resourceType: Resource.Type
    weak var manager: SyncPushEngineManager?

    init(type: Resource.Type, manager: SyncPushEngineManager) {
        self.resourceType = type
        self.manager = manager
    }

    func check() {
        guard let entityName = Resource.entity().name else {
            return
        }

        CoreDataHelper.persistentContainer.performBackgroundTask { context in
            let fetchRequest = NSFetchRequest(entityName: entityName) as NSFetchRequest<NSFetchRequestResult>
            fetchRequest.predicate = NSPredicate(format: "objectStateValue != %d", ObjectState.unchanged.rawValue)

            do {
                let objects = try context.fetch(fetchRequest)
                for case let object as (NSManagedObject & Pushable) in objects {
                    self.pushChanges(for: object.objectID)
                }
            } catch {
                ErrorManager.shared.report(error)
            }
        }
    }

    private func pushChanges(for managedObjectId: NSManagedObjectID) {
        self.manager?.addOperation {
            let context = CoreDataHelper.persistentContainer.newBackgroundContext()
            context.performAndWait {
                guard let object = try? context.existingObject(with: managedObjectId), let resource = object as? Resource else {
                    log.info("Resource to be pushed could not be found")
                    return
                }

                guard resource.objectState != .unchanged else {
                    log.info("No change to be pushed for resource of type \(type(of: resource).type)")
                    return
                }

                var pushFuture: Future<Void, XikoloError>?
                if resource.objectState == .modified {
                    pushFuture = self.manager?.syncEngine.saveResource(resource)
                } else if resource.objectState == .deleted {
                    pushFuture = self.manager?.syncEngine.deleteResource(resource)
                } else {
                    log.warning("unhandle resource modification")
                }

                // it makes only sense to retry on network errors
                pushFuture = pushFuture?.recoverWith { error -> Future<(), XikoloError> in
                    if case .network = error {
                        return Future(error: error)
                    } else if case let .synchronization(.api(.response(statusCode: statusCode, headers: _))) = error, 500 ... 599 ~= statusCode {
                        return Future(error: error)
                    }

                    log.error("Failed to push resource modification - \(error)")
                    ErrorManager.shared.report(error)
                    return Future(value: ())
                }

                guard pushFuture?.forced().value != nil else {
                    log.warning("Failed to push resource modification due to network issues")
                    return
                }

                // post sync actions
                if resource.objectState == .deleted {
                    context.delete(resource)
                    log.info("Deleted local resource of type: %@", type(of: resource).type)
                } else if resource.objectState == .new || resource.objectState == .modified {
                    resource.markAsUnchanged()
                }

                do {
                    try context.save()
                } catch {
                    log.error("while pushing core data changes: \(error)")
                    ErrorManager.shared.report(error)
                }
            }
        }
    }

}
