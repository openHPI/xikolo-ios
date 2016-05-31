//
//  CourseItemHelper.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 13.05.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import CoreData
import UIKit

class CourseItemHelper {

    static private let appDelegate = UIApplication.sharedApplication().delegate as! AbstractAppDelegate
    static private let managedContext = appDelegate.managedObjectContext
    static private let entity = NSEntityDescription.entityForName("CourseItem", inManagedObjectContext: managedContext)!

    static func getItemRequest(section: CourseSection) -> NSFetchRequest {
        let request = NSFetchRequest(entityName: "CourseItem")
        request.predicate = NSPredicate(format: "section = %@", section)
        // TODO: Sort by position once that attribute exists in the API.
        let titleSort = NSSortDescriptor(key: "title", ascending: true)
        request.sortDescriptors = [titleSort]
        return request
    }
    
    static func getItemRequest(course: Course) -> NSFetchRequest {
        let request = NSFetchRequest(entityName: "CourseItem")
        request.predicate = NSPredicate(format: "section.course = %@", course)
        // TODO: Sort by position once that attribute exists in the API.
        let titleSort = NSSortDescriptor(key: "title", ascending: true)
        request.sortDescriptors = [titleSort]
        return request
    }
    
    static func initializeSectionResultsController(request: NSFetchRequest) -> NSFetchedResultsController {
        // TODO: Add cache name
        return NSFetchedResultsController(fetchRequest: request, managedObjectContext: managedContext, sectionNameKeyPath: nil, cacheName: nil)
    }
    
    static func initializeItemResultsController(request: NSFetchRequest) -> NSFetchedResultsController {
        // TODO: Add cache name
        return NSFetchedResultsController(fetchRequest: request, managedObjectContext: managedContext, sectionNameKeyPath: "section.title", cacheName: nil)
    }

    static func syncCourseItems(section: CourseSection) {
        CourseItemProvider.getCourseItems(section.id!) { items, error in
            if let items = items {
                do {
                    try SpineModelHelper.syncObjects(items, inject:["section": section])
                } catch {
                    // TODO: Error handling.
                }
            }
            // TODO: Error handling
        }
    }

}
