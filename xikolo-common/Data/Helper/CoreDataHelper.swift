//
//  CoreDataHelper.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 02.06.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import CoreData
import UIKit

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
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            // TODO: check for space etc
            // TODO: change URL back to URL from earlier
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    static func saveViewContext () {
        if persistentContainer.viewContext.hasChanges {
            do {
                try persistentContainer.viewContext.save()
            } catch let error as NSError {
                NSLog("Cannot save managed object context: \(error), \(error.userInfo)")
            }
        }
    }

    static var viewContext = persistentContainer.viewContext
    static var backgroundContext = {
        return persistentContainer.newBackgroundContext()
    }()
    
    static fileprivate var managedObjectModel: NSManagedObjectModel = {
        let modelURL = Bundle.main.url(forResource: "xikolo", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()

    static func saveContext (_ context: NSManagedObjectContext) {
        if context.hasChanges {
            do {
                try context.save()
            } catch let error as NSError {
                NSLog("Cannot save managed object context: \(error), \(error.userInfo)")
            }
        }
    }

    static func createResultsController(_ fetchRequest: NSFetchRequest<NSFetchRequestResult>, sectionNameKeyPath: String?) -> NSFetchedResultsController<NSFetchRequestResult> {
        // TODO: Add cache name
        return NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: sectionNameKeyPath, cacheName: nil)
    }

    static func executeFetchRequest(_ request: NSFetchRequest<NSFetchRequestResult>) throws -> [BaseModel] {
        var baseModels: [BaseModel]?
        CoreDataHelper.persistentContainer.performBackgroundFetchAndWait(request, completion: { (inner: () throws -> [BaseModel]) -> Void in
            do {
                baseModels = try inner()
            } catch let error {
                fatalError("\(error)")
            }
        } )
        return baseModels!;

    }

    static func delete(_ object: NSManagedObject) {
        backgroundContext.delete(object)
        saveContext(backgroundContext)
    }

    static func clearCoreDataStorage() {
        managedObjectModel.entitiesByName.keys.forEach { (entityName) in
            clearCoreDataEntity(entityName)
        }
    }

    static func clearCoreDataEntity(_ entityName: String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try persistentContainer.persistentStoreCoordinator.execute(deleteRequest, with: backgroundContext)
        } catch {
            // TODO: handle the error
        }
    }

}

extension NSPersistentContainer {

    func performBackgroundLoadSpineAndWait(cdObject: BaseModel, spineObject: BaseModelSpine, completion: @escaping (_ inner: () throws -> Void) -> Void) {
        CoreDataHelper.backgroundContext.performAndWait {
            do {
                try cdObject.loadFromSpine(spineObject)
                completion({})
            } catch let error as NSError {
                completion({_ in throw XikoloError.coreData(error)})
            }
        }
    }

    func performBackgroundFetchAndWait(_ request: NSFetchRequest<NSFetchRequestResult>, completion: @escaping (_ inner: () throws -> [BaseModel]) -> Void) {
        CoreDataHelper.backgroundContext.performAndWait {
            do {
                let results = try CoreDataHelper.backgroundContext.fetch(request) as! [BaseModel]
                completion({_ in return results})
            } catch let error as NSError {
                completion({_ in throw XikoloError.coreData(error)})
            }
        }
    }

    func performBackgroundSyncAndWait(_ objectsToUpdateRequest: NSFetchRequest<NSFetchRequestResult>, spineObjects: [BaseModelSpine], inject: [String: AnyObject?]?, save: Bool, completion: @escaping (_ inner: () throws -> [BaseModel]) -> Void) {
        CoreDataHelper.backgroundContext.performAndWait {
            do {
                let objectsToUpdate = try CoreDataHelper.executeFetchRequest(objectsToUpdateRequest)
                let results = try SpineModelHelper.syncObjects(objectsToUpdate, spineObjects: spineObjects, inject: inject, save: save)
                completion({_ in return results})
            } catch let error as NSError {
                completion({_ in throw XikoloError.coreData(error)})
            }
        }
    }

    func performBackgroundSyncAndWait(_ objectsToUpdate: [BaseModel], spineObjects: [BaseModelSpine], inject: [String: AnyObject?]?, save: Bool, completion: @escaping (_ inner: () throws -> [BaseModel]) -> Void) {
        CoreDataHelper.backgroundContext.performAndWait {
            do {
                let results = try SpineModelHelper.syncObjects(objectsToUpdate, spineObjects: spineObjects, inject: inject, save: save)
                completion({_ in return results})
            } catch let error as NSError {
                completion({_ in throw XikoloError.coreData(error)})
            }
        }
    }
}
