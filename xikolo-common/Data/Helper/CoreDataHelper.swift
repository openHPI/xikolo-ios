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
        //container.persistentStoreDescriptions = [NSPersistentStoreDescription(url: coreDataDirectory)]
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
        do {
            return try persistentContainer.viewContext.fetch(request) as! [BaseModel]
        } catch let error as NSError {
            throw XikoloError.coreData(error)
        }
    }

    static func delete(_ object: NSManagedObject) {
        let context = persistentContainer.newBackgroundContext()
        context.delete(object)
        saveContext(context)
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
            try persistentContainer.persistentStoreCoordinator.execute(deleteRequest, with: persistentContainer.newBackgroundContext())
        } catch {
            // TODO: handle the error
        }
    }

}
