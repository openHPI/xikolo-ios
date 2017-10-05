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

    static fileprivate let genericPredicate = NSPredicate(format: "external_int != true")
    static fileprivate let enrolledPredicate = NSPredicate(format: "external_int != true AND enrollment != null")
    static fileprivate let unenrolledPredicate = NSPredicate(format: "external_int != true AND enrollment == null")
    static fileprivate let announcedPredicate = NSPredicate(format: "status = %@", "announced")
    static fileprivate let previewPredicate = NSPredicate(format: "status = %@", "preview")
    static fileprivate let activePredicate = NSPredicate(format: "status = %@", "active")
    static fileprivate let selfpacedPredicate = NSPredicate(format: "status = %@", "self-paced")
    static fileprivate let interestingPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [announcedPredicate,previewPredicate,activePredicate])
    static fileprivate let accessiblePredicate = NSPredicate(format: "accessible_int == true")
    static fileprivate let completedPredicate = NSPredicate(format: "enrollment.completed_int == 1")
    static fileprivate let notcompletedPredicate = NSPredicate(format: "enrollment.completed_int == 0")

    static func getGenericCoursesRequest() -> NSFetchRequest<Course> {
        let request: NSFetchRequest<Course> = Course.fetchRequest()
        let customOrderSort = NSSortDescriptor(key: "order", ascending: true)
        request.sortDescriptors = [customOrderSort]
        request.predicate = genericPredicate
        return request
    }

    static func getCourseRequest(for course: Course) -> NSFetchRequest<Course> {
        let request: NSFetchRequest<Course> = Course.fetchRequest()
        request.predicate = NSPredicate(format: "id = %@", course.id)
        return request
    }

    static func getAllCoursesRequest() -> NSFetchRequest<Course> {
        return getGenericCoursesRequest()
    }

    static func getUnenrolledCoursesRequest() -> NSFetchRequest<Course> {
        let request = getGenericCoursesRequest()
        request.predicate = unenrolledPredicate
        return request
    }

    static func getEnrolledCoursesRequest() -> NSFetchRequest<Course> {
        let request = getGenericCoursesRequest()
        request.predicate = enrolledPredicate
        return request
    }

    static func getInterestingCoursesRequest() -> NSFetchRequest<Course> {
        let request = getGenericCoursesRequest()
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [unenrolledPredicate, interestingPredicate])
        return request
    }

    static func getPastCoursesRequest() -> NSFetchRequest<Course> {
        let request = getGenericCoursesRequest()
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [unenrolledPredicate, selfpacedPredicate])
        return request
    }

    static func getEnrolledAccessibleCoursesRequest() -> NSFetchRequest<Course> {
        let request = getGenericCoursesRequest()
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [enrolledPredicate, accessiblePredicate, notcompletedPredicate])
        return request
    }

    static func getEnrolledCurrentCoursesRequest() -> NSFetchRequest<Course> {
        let request = getGenericCoursesRequest()
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [enrolledPredicate, accessiblePredicate, notcompletedPredicate, activePredicate])
        return request
    }

    static func getEnrolledSelfPacedCoursesRequest() -> NSFetchRequest<Course> {
        let request = getGenericCoursesRequest()
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [enrolledPredicate, accessiblePredicate, notcompletedPredicate, selfpacedPredicate])
        return request
    }

    static func getEnrolledUpcomingCoursesRequest() -> NSFetchRequest<Course> {
        let request = getGenericCoursesRequest()
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [enrolledPredicate, announcedPredicate, notcompletedPredicate])
        return request
    }

    static func getCompletedCoursesRequest() -> NSFetchRequest<Course> {
        let request = getGenericCoursesRequest()
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [enrolledPredicate, completedPredicate])
        return request
    }

    static func getSectionedRequest() -> NSFetchRequest<Course> {
        let request = getGenericCoursesRequest()
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

    static func getByID(_ id: String) -> Course? {
        let request: NSFetchRequest<Course> = Course.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        request.fetchLimit = 1
        do {
            let courses = try CoreDataHelper.executeFetchRequest(request)
            return courses.first
        } catch {
            return nil
        }
    }

    static func getBySlug(_ slug: String) -> Course? {
        let request: NSFetchRequest<Course> = Course.fetchRequest()
        request.predicate = NSPredicate(format: "slug == %@", slug)
        request.fetchLimit = 1
        do {
            return try CoreDataHelper.executeFetchRequest(request).first
        } catch {
            return nil
        }
    }

    static func refreshCourses() -> Future<[Course], XikoloError> {
        return CourseProvider.getCourses().flatMap { spineCourses -> Future<[Course], XikoloError> in
            let request = getGenericCoursesRequest()
            return SpineModelHelper.syncObjectsFuture(request, spineObjects: spineCourses, inject: nil, save: true)
        }
    }

    static func refreshCourse(_ course: Course) -> Future<[Course], XikoloError> { // TODO: Refactor to not return array
        return CourseProvider.getCourse(course.id).flatMap { spineCourse -> Future<[Course], XikoloError> in
            let request = getCourseRequest(for: course)
            return SpineModelHelper.syncObjectsFuture(request, spineObjects: [spineCourse], inject: nil, save: true)
        }
    }

}
