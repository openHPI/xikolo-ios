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

    static func getGenericCoursesRequest() -> NSFetchRequest<NSFetchRequestResult> {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Course")
        let customOrderSort = NSSortDescriptor(key: "order", ascending: true)
        request.sortDescriptors = [customOrderSort]
        request.predicate = genericPredicate
        return request
    }

    static func getAllCoursesRequest() -> NSFetchRequest<NSFetchRequestResult> {
        return getGenericCoursesRequest()
    }

    static func getUnenrolledCoursesRequest() -> NSFetchRequest<NSFetchRequestResult> {
        let request = getGenericCoursesRequest()
        request.predicate = unenrolledPredicate
        return request
    }

    static func getEnrolledCoursesRequest() -> NSFetchRequest<NSFetchRequestResult> {
        let request = getGenericCoursesRequest()
        request.predicate = enrolledPredicate
        return request
    }

    static func getInterestingCoursesRequest() -> NSFetchRequest<NSFetchRequestResult> {
        let request = getGenericCoursesRequest()
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [unenrolledPredicate, interestingPredicate])
        return request
    }

    static func getPastCoursesRequest() -> NSFetchRequest<NSFetchRequestResult> {
        let request = getGenericCoursesRequest()
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [unenrolledPredicate, selfpacedPredicate])
        return request
    }

    static func getEnrolledAccessibleCoursesRequest() -> NSFetchRequest<NSFetchRequestResult> {
        let request = getGenericCoursesRequest()
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [enrolledPredicate, accessiblePredicate, notcompletedPredicate])
        return request
    }

    static func getEnrolledUpcomingCoursesRequest() -> NSFetchRequest<NSFetchRequestResult> {
        let request = getGenericCoursesRequest()
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [enrolledPredicate, announcedPredicate, notcompletedPredicate])
        return request
    }

    static func getCompletedCoursesRequest() -> NSFetchRequest<NSFetchRequestResult> {
        let request = getGenericCoursesRequest()
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [enrolledPredicate, completedPredicate])
        return request
    }

    static func getSectionedRequest() -> NSFetchRequest<NSFetchRequestResult> {
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
