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

    static fileprivate let entity = NSEntityDescription.entity(forEntityName: "Course", in: CoreDataHelper.managedContext)!

    static func getGenericCoursesRequest() -> NSFetchRequest<NSFetchRequestResult> {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Course")
        let startDateSort = NSSortDescriptor(key: "start_at", ascending: false)
        request.sortDescriptors = [startDateSort]
        return request
    }

    static func getAllCoursesRequest() -> NSFetchRequest<NSFetchRequestResult> {
        let request = getGenericCoursesRequest()
        request.predicate = NSPredicate(format: "external_int != true")
        return request
    }

    static func getUnenrolledCoursesRequest() -> NSFetchRequest<NSFetchRequestResult> {
        let request = getGenericCoursesRequest()
        request.predicate = NSPredicate(format: "external_int != true AND hidden_int != true AND enrollment == null")
        return request
    }

    static func getEnrolledCoursesRequest() -> NSFetchRequest<NSFetchRequestResult> {
        let request = getGenericCoursesRequest()
        request.predicate = NSPredicate(format: "external_int != true AND enrollment != null")
        return request
    }

    static func getEnrolledAccessibleCoursesRequest() -> NSFetchRequest<NSFetchRequestResult> {
        let request = getGenericCoursesRequest()
        request.predicate = NSPredicate(format: "external_int != true AND enrollment != null AND accessible_int == true")
        return request
    }

    static func getSectionedRequest() -> NSFetchRequest<NSFetchRequestResult> {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Course")
        request.predicate = NSPredicate(format: "external_int != true")
        let enrolledSort = NSSortDescriptor(key: "enrollment", ascending: false)
        let startDateSort = NSSortDescriptor(key: "start_at", ascending: false)
        request.sortDescriptors = [enrolledSort, startDateSort]
        return request
    }

    static func getNumberOfEnrolledCourses() throws -> Int {
        let request = getEnrolledCoursesRequest()
        let courses = try CoreDataHelper.executeFetchRequest(request)
        return courses.count
    }

    static func getByID(_ id: String) throws -> Course? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Course")
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
            let request = getGenericCoursesRequest()
            return SpineModelHelper.syncObjectsFuture(request, spineObjects: spineCourses, inject: nil, save: true)
        }.map { cdCourses in
            return cdCourses as! [Course]
        }
    }

}
