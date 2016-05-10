//
//  CourseSectionHelper.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 11.05.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import CoreData
import UIKit

class CourseSectionHelper {

    static private let appDelegate = UIApplication.sharedApplication().delegate as! AbstractAppDelegate
    static private let managedContext = appDelegate.managedObjectContext
    static private let entity = NSEntityDescription.entityForName("CourseSection", inManagedObjectContext: managedContext)!

    static func getSectionRequest(course: Course) -> NSFetchRequest {
        let request = NSFetchRequest(entityName: "CourseSection")
        request.predicate = NSPredicate(format: "course = %@", course)
        // TODO: Sort by position once that attribute exists in the API.
        let titleSort = NSSortDescriptor(key: "title", ascending: true)
        request.sortDescriptors = [titleSort]
        return request
    }

    static func initializeFetchedResultsController(request: NSFetchRequest) -> NSFetchedResultsController {
        // TODO: Add cache name
        return NSFetchedResultsController(fetchRequest: request, managedObjectContext: managedContext, sectionNameKeyPath: nil, cacheName: nil)
    }

    static func syncCourseSections(course: Course) {
        CourseSectionProvider.getCourseSections(course.id!) { sections, error in
            if let sections = sections {
                do {
                    try SpineModelHelper.syncObjects(CourseSection.self, spineObjects: sections, inject:["course": course])
                } catch {
                    // TODO: Error handling.
                }
            }
            // TODO: Error handling
        }
    }

}
