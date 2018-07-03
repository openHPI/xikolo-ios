//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures
import CoreData
import Foundation

public class SyncPushEngine {

    var types: [(NSManagedObject & Pushable).Type] = []

    public static let shared = SyncPushEngine()

    public var delegate: SyncPushEngineDelegate?

    private let persistentContainerQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()

    public func startObserving() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(coreDataChange(note:)),
                                               name: NSNotification.Name.NSManagedObjectContextObjectsDidChange,
                                               object: CoreDataHelper.viewContext)
    }

    public func stopObserving() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: CoreDataHelper.viewContext)
    }

    public func register(_ newType: NSManagedObject.Type) {
        guard let pushableType = newType as? (NSManagedObject & Pushable).Type else {
            return
        }

        if !self.types.contains(where: { $0 == newType }) {
            self.types.append(pushableType)
        }
    }

    @objc private func coreDataChange(note: Notification) {
        let shouldCheckForChangesToPush = [NSUpdatedObjectsKey, NSInsertedObjectsKey, NSRefreshedObjectsKey].map { key in
            guard let objects = note.userInfo?[key] as? Set<NSManagedObject>, !objects.isEmpty else { return false }
            return objects.contains { $0 is Pushable }
        }.reduce(false) { $0 || $1 }

        if shouldCheckForChangesToPush {
            self.check()
        }
    }

    func check() {
        for type in self.types {
            guard let entityName = type.entity().name else {
                continue
            }

            CoreDataHelper.persistentContainer.performBackgroundTask { context in
                let fetchRequest = NSFetchRequest(entityName: entityName) as NSFetchRequest<NSFetchRequestResult>
                if type is Pullable.Type {
                    fetchRequest.predicate = NSPredicate(format: "objectStateValue != %d", ObjectState.unchanged.rawValue)
                }

                if let objects = try? context.fetch(fetchRequest) {
                    for case let object as (NSManagedObject & Pushable) in objects {
                        self.pushChanges(for: object.objectID)
                    }
                }
            }
        }
    }

    private func pushChanges(for managedObjectId: NSManagedObjectID) {
        self.persistentContainerQueue.addOperation {
            let context = CoreDataHelper.persistentContainer.newBackgroundContext()
            context.performAndWait {
                guard let object = try? context.existingObject(with: managedObjectId), let resource = object as? (NSManagedObject & Pushable) else {
                    log.info("Resource to be pushed could not be found")
                    return
                }

                guard resource.objectState != .unchanged else {
                    log.info("No change to be pushed for resource of type \(type(of: resource).type)")
                    return
                }

                var pushFuture: Future<Void, XikoloError>?
                if let pullableResource = resource as? (Pullable & Pushable), resource.objectState == .modified {
                    pushFuture = SyncEngine.shared.saveResource(pullableResource)
                } else if resource.objectState == .new, !(resource is Pullable) {
                    pushFuture = SyncEngine.shared.createResource(resource)
                } else if let deletableResource = resource as? (Pullable & Pushable), resource.objectState == .deleted {
                    pushFuture = SyncEngine.shared.deleteResource(deletableResource)
                } else {
                    log.warning("unhandle resource modification")
                }

                // it makes only sense to retry on network errors
                pushFuture = pushFuture?.recoverWith { error -> Future<(), XikoloError> in
                    if case .network = error {
                        return Future(error: error)
                    } else if case let .api(.responseError(statusCode: statusCode, headers: _)) = error, 500 ... 599 ~= statusCode {
                        return Future(error: error)
                    }

                    log.error("Failed to push resource modification - \(error)")
                    self.delegate?.didFailToPushResourceModification(withError: error)
                    return Future(value: ())
                }

                guard let result = pushFuture?.forced(), case .success(_) = result else {
                    log.warning("Failed to push resource modification due to network issues")
                    return
                }

                // post sync actions
                if resource.objectState == .deleted || !(resource is Pullable) {
                    context.delete(resource)
                    log.verbose("Deleted local resource of type: \(type(of: resource).type)")
                } else if resource.objectState == .new || resource.objectState == .modified {
                    resource.markAsUnchanged()
                }

                do {
                    try context.save()
                } catch {
                    log.error("while pushing core data changes: \(error)")
                }
            }
        }
    }

}

public protocol SyncPushEngineDelegate {
    func didFailToPushResourceModification(withError error: XikoloError)
}
