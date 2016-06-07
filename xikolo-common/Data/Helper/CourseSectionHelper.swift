//
//  CourseSectionHelper.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 11.05.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import BrightFutures
import CoreData
import Result

class CourseSectionHelper : CoreDataHelper {

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

    static func syncCourseSections(course: Course) -> Future<[CourseSection], XikoloError> {
        return CourseSectionProvider.getCourseSections(course.id).flatMap { spineSections in
            future {
                do {
                    let cdSections = try SpineModelHelper.syncObjects(spineSections, inject:["course": course])
                    return Result.Success(cdSections as! [CourseSection])
                } catch let error as XikoloError {
                    return Result.Failure(error)
                } catch {
                    return Result.Failure(XikoloError.UnknownError(error))
                }
            }
        }
    }

}
