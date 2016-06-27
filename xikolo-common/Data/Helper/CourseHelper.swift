//
//  CourseHelper.swift
//  xikolo-ios
//
//  Created by Jonas Müller on 30.09.15.
//  Copyright © 2015 HPI. All rights reserved.
//

import CoreData
import UIKit

class CourseHelper {

    static private let entity = NSEntityDescription.entityForName("Course", inManagedObjectContext: CoreDataHelper.managedContext)!

    static func getAllCoursesRequest() -> NSFetchRequest {
        let request = NSFetchRequest(entityName: "Course")
        let startDateSort = NSSortDescriptor(key: "start_date", ascending: false)
        request.sortDescriptors = [startDateSort]
        return request
    }

    static func getMyCoursesRequest() -> NSFetchRequest {
        let request = getAllCoursesRequest()
        request.predicate = NSPredicate(format: "is_enrolled_int == true")
        return request
    }

    static func getSectionedRequest() -> NSFetchRequest {
        let request = NSFetchRequest(entityName: "Course")
        let enrolledSort = NSSortDescriptor(key: "is_enrolled_int", ascending: false)
        let startDateSort = NSSortDescriptor(key: "start_date", ascending: false)
        request.sortDescriptors = [enrolledSort, startDateSort]
        return request
    }

    static func getNumberOfEnrolledCourses() throws -> Int {
        let request = getMyCoursesRequest()
        let courses = try CoreDataHelper.executeFetchRequest(request)
        return courses.count
    }

    static func getByID(id: String) throws -> Course? {
        let request = NSFetchRequest(entityName: "Course")
        request.predicate = NSPredicate(format: "id == %@", id)
        request.fetchLimit = 1
        let courses = try CoreDataHelper.executeFetchRequest(request) as! [Course]
        if courses.isEmpty {
            return nil
        }
        return courses[0]
    }

    static func refreshCourses() {
        CourseProvider.getCourses { (courses, error) in
            if let courses = courses {
                do {
                    let request = getAllCoursesRequest()
                    try syncCourses(request, courses: courses)
                } catch {
                    // TODO: Error handling
                }
            }
        }
    }

    private static func syncCourses(objectsToUpdateRequest: NSFetchRequest, courses: [[String: AnyObject]]) throws {
        var objectsToUpdate = try CoreDataHelper.executeFetchRequest(objectsToUpdateRequest) as! [Course]

        let request = NSFetchRequest(entityName: "Course")
        for course in courses {
            if let id = course["id"] as? String {
                let predicate = NSPredicate(format: "id == %@", argumentArray: [id])
                request.predicate = predicate

                var cdCourse: Course!
                let results = try CoreDataHelper.executeFetchRequest(request) as! [Course]
                if (results.count > 0) {
                    cdCourse = results[0]
                } else {
                    cdCourse = Course(entity: entity, insertIntoManagedObjectContext: CoreDataHelper.managedContext)
                    cdCourse.id = id
                }
                cdCourse.loadFromDict(course)

                if let index = objectsToUpdate.indexOf(cdCourse) {
                    objectsToUpdate.removeAtIndex(index)
                }
            }
        }
        for object in objectsToUpdate {
            CoreDataHelper.managedContext.deleteObject(object)
        }
        CoreDataHelper.saveContext()
    }

}
