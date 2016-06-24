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

    static private var applicationCachesDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "de.xikolo.xikolo-ios" in the application's caches Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.CachesDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()

    static private var managedObjectModel: NSManagedObjectModel = {
        let modelURL = NSBundle.mainBundle().URLForResource("xikolo", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()

    static private var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        let url = applicationCachesDirectory.URLByAppendingPathComponent("xikolo.sqlite")
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch let error as NSError {
            NSLog("Error adding persistent CoreData store: \(error), \(error.userInfo)")
        }
        return coordinator
    }()

    static var managedContext: NSManagedObjectContext = {
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
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

    static func executeFetchRequest(request: NSFetchRequest) throws -> [BaseModel] {
        do {
            return try managedContext.executeFetchRequest(request) as! [BaseModel]
        } catch let error as NSError {
            throw XikoloError.CoreData(error)
        }
    }

}
