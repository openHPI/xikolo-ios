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

    static fileprivate var managedObjectModel: NSManagedObjectModel = {
        let modelURL = Bundle.main.url(forResource: "xikolo", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()

    static fileprivate var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        let url = coreDataDirectory.appendingPathComponent("xikolo.sqlite")
        let options = [NSMigratePersistentStoresAutomaticallyOption: true,
                        NSInferMappingModelAutomaticallyOption: true]

        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: options)
        } catch let error as NSError {
            NSLog("Error adding persistent CoreData store: \(error), \(error.userInfo)")
        }
        return coordinator
    }()

    static var managedContext: NSManagedObjectContext = {
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator
        return managedObjectContext
    }()

    static func saveContext () {
        if managedContext.hasChanges {
            do {
                try managedContext.save()
            } catch let error as NSError {
                NSLog("Cannot save managed object context: \(error), \(error.userInfo)")
            }
        }
    }

    static func createResultsController(_ fetchRequest: NSFetchRequest<NSFetchRequestResult>, sectionNameKeyPath: String?) -> NSFetchedResultsController<NSFetchRequestResult> {
        // TODO: Add cache name
        return NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedContext, sectionNameKeyPath: sectionNameKeyPath, cacheName: nil)
    }

    static func executeFetchRequest(_ request: NSFetchRequest<NSFetchRequestResult>) throws -> [BaseModel] {
        do {
            return try managedContext.fetch(request) as! [BaseModel]
        } catch let error as NSError {
            throw XikoloError.coreData(error)
        }
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
            try persistentStoreCoordinator.execute(deleteRequest, with: managedContext)
        } catch {
            // TODO: handle the error
        }
    }

}
