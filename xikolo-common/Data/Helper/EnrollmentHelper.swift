//
//  EnrollmentHelper.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 16.03.17.
//  Copyright © 2017 HPI. All rights reserved.
//

import BrightFutures
import CoreData

class EnrollmentHelper {

    static func getEnrollmentsRequest() -> NSFetchRequest<Enrollment> {
        let request: NSFetchRequest<Enrollment> = Enrollment.fetchRequest()
        return request
    }

    static func syncEnrollments() -> Future<[Enrollment], XikoloError> {
        return EnrollmentProvider.getEnrollments().flatMap { spineEnrollments -> Future<[Enrollment], XikoloError> in
            let request = getEnrollmentsRequest()
            return SpineModelHelper.syncObjectsFuture(request, spineObjects: spineEnrollments, inject: nil, save: true)
        }
    }

    static func createEnrollment(for course: Course) -> Future<Void, XikoloError> {
        let promise = Promise<Void, XikoloError>()

        let courseSpine = CourseSpine(course: course)
        let enrollmentSpine = EnrollmentSpine(course: courseSpine)
        SpineHelper.save(enrollmentSpine).onSuccess { enrollmentSpine in
            NotificationCenter.default.post(name: NotificationKeys.createdEnrollmentKey, object: nil)
            return promise.success()
        }.onFailure { xikoloError in
            return promise.failure(xikoloError)
        }
        return promise.future
    }

    static func delete(_ enrollment: Enrollment) -> Future<Void, XikoloError> {
        let promise = Promise<Void, XikoloError>()

        let enrollmentSpine = EnrollmentSpine(from: enrollment)
        SpineHelper.delete(enrollmentSpine).onSuccess { _ in
            CoreDataHelper.delete(enrollment)
            NotificationCenter.default.post(name: NotificationKeys.deletedEnrollmentKey, object: enrollment)
            return promise.success()
        }.onFailure { xikoloError in
            return promise.failure(xikoloError)
        }
        return promise.future
    }

    static func markAsCompleted(_ course: Course) -> Future<EnrollmentSpine, XikoloError> {
        course.enrollment?.completed = true
        return SpineHelper.save(EnrollmentSpine(from: course.enrollment!))
    }

}
