//
//  CourseHelper.swift
//  xikolo-ios
//
//  Created by Jonas Müller on 30.09.15.
//  Copyright © 2015 HPI. All rights reserved.
//

import BrightFutures
import CoreData

class CourseHelper {

    static private let entity = NSEntityDescription.entityForName("Course", inManagedObjectContext: CoreDataHelper.managedContext)!

    static func getAllCoursesRequest() -> NSFetchRequest {
        let request = NSFetchRequest(entityName: "Course")
        request.predicate = NSPredicate(format: "external_int != true")
        let startDateSort = NSSortDescriptor(key: "start_at", ascending: false)
        request.sortDescriptors = [startDateSort]
        return request
    }

    static func getMyCoursesRequest() -> NSFetchRequest {
        let request = getAllCoursesRequest()
        request.predicate = NSPredicate(format: "enrollment != null")
        return request
    }

    static func getMyAccessibleCoursesRequest() -> NSFetchRequest {
        let request = getAllCoursesRequest()
        request.predicate = NSPredicate(format: "enrollment != null AND accessible_int == true")
        return request
    }

    static func getSectionedRequest() -> NSFetchRequest {
        let request = NSFetchRequest(entityName: "Course")
        request.predicate = NSPredicate(format: "external_int != true")
        let enrolledSort = NSSortDescriptor(key: "enrollment", ascending: false)
        let startDateSort = NSSortDescriptor(key: "start_at", ascending: false)
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

    static func refreshCourses() -> Future<[Course], XikoloError> {
        return CourseProvider.getCourses().flatMap { spineCourses -> Future<[BaseModel], XikoloError> in
            let request = getAllCoursesRequest()
            return SpineModelHelper.syncObjectsFuture(request, spineObjects: spineCourses, inject: nil, save: true)
        }.map { cdCourses in
            return cdCourses as! [Course]
        }
    }

}
