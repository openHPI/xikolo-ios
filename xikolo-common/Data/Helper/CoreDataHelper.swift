//
//  CoreDataHelper.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 02.06.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import CoreData
//import UIKit
import BrightFutures
import Result

class CoreDataHelper {

    static fileprivate var coreDataDirectory: URL = {
        let fileManager = FileManager.default

        #if os(tvOS)
            let groupURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: Brand.AppGroupID)!
            return groupURL.appendingPathComponent("Library/Caches")
        #else
            let urls = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
            return urls[urls.count-1]
        #endif
    }()

    static var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer.init(name: "CoreData", managedObjectModel: managedObjectModel)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            // TODO: check for space etc
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
            container.viewContext.automaticallyMergesChangesFromParent = true
        })
        return container
    }()

    static let viewContext = persistentContainer.viewContext
    static func newBackgroundContext() -> NSManagedObjectContext {
        return self.persistentContainer.newBackgroundContext()
    }

    static fileprivate var managedObjectModel: NSManagedObjectModel = {
        let modelURL = Bundle.main.url(forResource: "xikolo", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()

    static func save(_ context: NSManagedObjectContext) -> Future<Void, XikoloError> {
        let promise = Promise<Void, XikoloError>()

        context.perform {
            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    promise.failure(.coreData(error))
                }
            }
            promise.success(())
        }

        return promise.future
    }

    static func createResultsController<T: NSManagedObject>(_ fetchRequest: NSFetchRequest<T>,
                                                            sectionNameKeyPath: String?) -> NSFetchedResultsController<T> {
        // TODO: Add cache name
        return NSFetchedResultsController<T>(fetchRequest: fetchRequest,
                                             managedObjectContext: persistentContainer.viewContext,
                                             sectionNameKeyPath: sectionNameKeyPath,
                                             cacheName: nil)
    }

//    static func executeFetchRequest<T: NSManagedObject>(_ request: NSFetchRequest<T>) throws -> [T] {
//        var baseModels: [T]?
//        CoreDataHelper.persistentContainer.performBackgroundFetchAndWait(request, completion: { (inner: () throws -> [T]) -> Void in
//            do {
//                baseModels = try inner()
//            } catch let error {
//                fatalError("\(error)")
//            }
//        } )
//        return baseModels!
//
//    }

    enum FetchContext {
        case viewContext
        case newBackgroundContext

        func managedObjectContext() -> NSManagedObjectContext {
            switch self {
            case .viewContext:
                return CoreDataHelper.viewContext
            case .newBackgroundContext:
                return CoreDataHelper.newBackgroundContext()
            }
        }
    }

    static func fetchMultipleObjects<Resource>(fetchRequest request: NSFetchRequest<Resource>, inContext context: FetchContext) -> Future<[Resource], XikoloError> where Resource : NSManagedObject{
        let promise = Promise<[Resource], XikoloError>()
        let managedObjectContext = context.managedObjectContext()

        managedObjectContext.perform {
            do {
                let objects = try managedObjectContext.fetch(request)
                promise.success(objects)
            } catch {
                promise.failure(.coreData(error))
            }
        }

        return promise.future
    }

    static func fetchSingleObject<Resource>(fetchRequest request: NSFetchRequest<Resource>, inContext context: FetchContext) -> Future<Resource, XikoloError> where Resource : NSManagedObject{
        return self.fetchMultipleObjects(fetchRequest: request, inContext: context).flatMap { objects -> Result<Resource, XikoloError> in
            if let object = objects.first {
                return .success(object)
            } else {
                return .failure(.coreDataObjectNotFound)
            }
        }
    }

    static func fetchMultipleObjectsAndWait<Resource>(fetchRequest request: NSFetchRequest<Resource>, inContext context: FetchContext) -> Result<[Resource], XikoloError> where Resource : NSManagedObject{
        var result: Result<[Resource], XikoloError> = .failure(.totallyUnknownError)
        let managedObjectContext = context.managedObjectContext()

        managedObjectContext.performAndWait {
            do {
                let objects = try managedObjectContext.fetch(request)
                result = .success(objects)
            } catch {
                result = .failure(.coreData(error))
            }
        }

        return result
    }

    static func fetchSingleObjectAndWait<Resource>(fetchRequest request: NSFetchRequest<Resource>, inContext context: FetchContext) -> Result<Resource, XikoloError> where Resource : NSManagedObject {
        return self.fetchMultipleObjectsAndWait(fetchRequest: request, inContext: context).flatMap { objects -> Result<Resource, XikoloError> in
            if let object = objects.first {
                return .success(object)
            } else {
                return .failure(.coreDataObjectNotFound)
            }
        }
    }


    static func delete(_ object: NSManagedObject) -> Future<Void, XikoloError> {
        return Future { complete in
            self.persistentContainer.performBackgroundTask { context in
                context.delete(context.object(with: object.objectID))
                self.save(context).onComplete { complete($0) }
            }
        }
    }

    static func clearCoreDataStorage() {
        for entityName in managedObjectModel.entitiesByName.keys {
            self.clearCoreDataEntity(entityName)
        }
    }

    static func clearCoreDataEntity(_ entityName: String) {
        self.persistentContainer.performBackgroundTask { privateManagedObjectContext in
            privateManagedObjectContext.shouldDeleteInaccessibleFaults = true
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            deleteRequest.resultType = .resultTypeObjectIDs

            do {
                let result = try privateManagedObjectContext.execute(deleteRequest) as? NSBatchDeleteResult
                guard let objectIDArray = result?.result as? [NSManagedObjectID] else { return }
                let changes = [NSDeletedObjectsKey : objectIDArray]
                print("Try to delete all enities of \(entityName) (\(objectIDArray.count) enities)")
                NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [self.viewContext])
                try privateManagedObjectContext.save()
            } catch {
                print("Failed to bulk delete all enities of \(entityName) - \(error)")
            }
        }
    }

}

//extension NSPersistentContainer {
//
//    func performBackgroundLoadSpineAndWait(cdObject: BaseModel, spineObject: BaseModelSpine, completion: @escaping (_ inner: () throws -> Void) -> Void) {
//        CoreDataHelper.backgroundContext.performAndWait {
//            do {
//                try cdObject.loadFromSpine(spineObject)
//                completion({})
//            } catch let error as NSError {
//                completion({ throw XikoloError.coreData(error)})
//            }
//        }
//    }
//
//    func performBackgroundFetchAndWait<T: BaseModel>(_ request: NSFetchRequest<T>, completion: @escaping (_ inner: () throws -> [T]) -> Void) {
//        CoreDataHelper.backgroundContext.performAndWait {
//            do {
//                let results = try CoreDataHelper.backgroundContext.fetch(request)
//                completion({ return results})
//            } catch let error as NSError {
//                completion({ throw XikoloError.coreData(error)})
//            }
//        }
//    }
//
//    func performBackgroundSyncAndWait<T: BaseModel>(_ objectsToUpdateRequest: NSFetchRequest<T>, spineObjects: [BaseModelSpine], inject: [String: AnyObject?]?, save: Bool, completion: @escaping (_ inner: () throws -> [T]) -> Void) {
//        CoreDataHelper.backgroundContext.performAndWait {
//            do {
//                let objectsToUpdate = try CoreDataHelper.executeFetchRequest(objectsToUpdateRequest)
//                let results = try SpineModelHelper.syncObjects(objectsToUpdate, spineObjects: spineObjects, inject: inject, save: save)
//                completion({ return results})
//            } catch let error as NSError {
//                completion({ throw XikoloError.coreData(error)})
//            }
//        }
//    }
//
//    func performBackgroundSyncAndWait<T: BaseModel>(_ objectsToUpdate: [T], spineObjects: [BaseModelSpine], inject: [String: AnyObject?]?, save: Bool, completion: @escaping (_ inner: () throws -> [T]) -> Void) {
//        CoreDataHelper.backgroundContext.performAndWait {
//            do {
//                let results = try SpineModelHelper.syncObjects(objectsToUpdate, spineObjects: spineObjects, inject: inject, save: save)
//                completion({ return results})
//            } catch let error as NSError {
//                completion({ throw XikoloError.coreData(error)})
//            }
//        }
//    }
//}

