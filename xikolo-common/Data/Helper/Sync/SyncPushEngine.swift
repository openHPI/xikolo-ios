//
//  SyncPushEngine.swift
//  xikolo-ios
//
//  Created by Max Bothe on 24.11.17.
//  Copyright © 2017 HPI. All rights reserved.
//

import Foundation
import CoreData
import BrightFutures

class SyncPushEngine {

    var types: [(NSManagedObject & Pushable).Type] = []

    static let shared = SyncPushEngine()
    private let persistentContainerQueue: OperationQueue = {
        let queue = OperationQueue();
        queue.maxConcurrentOperationCount = 1;
        return queue;
    }()

    func register(_ newType: (NSManagedObject & Pushable).Type) {
        if !self.types.contains(where: { $0 == newType }) {
            self.types.append(newType)
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
                    pushFuture = SyncHelper.saveResource(pullableResource)
                } else if resource.objectState == .new, !(resource is Pullable) {
                    pushFuture = SyncHelper.createResource(resource)
                } else if let deletableResource = resource as? (Pullable & Pushable), resource.objectState == .deleted {
                    pushFuture = SyncHelper.deleteResource(deletableResource)
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
                    CrashlyticsHelper.shared.recordError(error)
                    log.error("Failed to push resource modification - \(error)")
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
