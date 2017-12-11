//
//  EnrollmentHelper.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 16.03.17.
//  Copyright © 2017 HPI. All rights reserved.
//

import Foundation
import CoreData
import BrightFutures
import Result

struct EnrollmentHelper {

    static func syncEnrollments() -> Future<[NSManagedObjectID], XikoloError> {
        guard UserProfileHelper.isLoggedIn() else {
            return Future(value: [])
        }

        let query = MultipleResourcesQuery(type: Enrollment.self)
        return SyncEngine.syncResources(withFetchRequest: EnrollmentHelper.FetchRequest.allEnrollements, withQuery: query)
    }

    static func createEnrollment(for course: Course) -> Future<Void, XikoloError> {
        let promise = Promise<Void, XikoloError>()

        CoreDataHelper.persistentContainer.performBackgroundTask { context in
            let course = context.object(with: course.objectID) as Course
            let _ = Enrollment(forCourse: course, inContext: context)
            let saveResult = context.saveWithResult()

            if case .success(_) = saveResult {
                NotificationCenter.default.post(name: NotificationKeys.createdEnrollmentKey, object: nil)
            }

            promise.complete(saveResult)
        }

        return promise.future
    }

    static func delete(_ enrollment: Enrollment?) -> Future<Void, XikoloError> {
        guard let enrollment = enrollment else {
            return Future(error: .missingEnrollment)
        }

        let promise = Promise<Void, XikoloError>()

        CoreDataHelper.persistentContainer.performBackgroundTask { context in
            let enrollment = context.object(with: enrollment.objectID) as Enrollment
            enrollment.objectState = .deleted
            let saveResult = context.saveWithResult()

            if case .success(_) = saveResult {
                NotificationCenter.default.post(name: NotificationKeys.deletedEnrollmentKey, object: enrollment)
            }

            promise.complete(saveResult)
        }

        return promise.future
    }

    static func markAsCompleted(_ course: Course) -> Future<Void, XikoloError> {
        guard let enrollment = course.enrollment else {
            return Future(error: .missingEnrollment)
        }

        guard !enrollment.completed else {
            return Future(value: ())
        }

        let promise = Promise<Void, XikoloError>()

        CoreDataHelper.persistentContainer.performBackgroundTask { context in
            let enrollment = context.object(with: enrollment.objectID) as Enrollment
            enrollment.completed = true
            if enrollment.objectState != .new, enrollment.objectState != .deleted {
                enrollment.objectState = .modified
            }
            promise.complete(context.saveWithResult())
        }

        return promise.future
    }
}
