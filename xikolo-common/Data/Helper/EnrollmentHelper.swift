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

    static func createEnrollment(for course: Course) -> Future<Void, XikoloError> {
        let promise = Promise<Void, XikoloError>()

        CoreDataHelper.persistentContainer.performBackgroundTask { context in
            guard let course = context.existingTypedObject(with: course.objectID) as? Course else {
                promise.failure(.missingResource(ofType: Course.self))
                return
            }

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
            return Future(error: .missingResource(ofType: Enrollment.self))
        }

        let promise = Promise<Void, XikoloError>()

        CoreDataHelper.persistentContainer.performBackgroundTask { context in
            guard let enrollment = context.existingTypedObject(with: enrollment.objectID) as? Enrollment else {
                promise.success(())
                return
            }

            enrollment.objectState = .deleted
            let saveResult = context.saveWithResult()

            if case .success(_) = saveResult {
                NotificationCenter.default.post(name: NotificationKeys.deletedEnrollmentKey, object: enrollment)
            }

            promise.complete(saveResult)
        }

        return promise.future
    }

    @discardableResult static func markAsCompleted(_ course: Course) -> Future<Void, XikoloError> {
        guard let enrollment = course.enrollment else {
            return Future(error: .missingResource(ofType: Enrollment.self))
        }

        guard !enrollment.completed else {
            return Future(value: ())
        }

        let promise = Promise<Void, XikoloError>()

        CoreDataHelper.persistentContainer.performBackgroundTask { context in
            guard let enrollment = context.existingTypedObject(with: enrollment.objectID) as? Enrollment else {
                promise.failure(.missingResource(ofType: Enrollment.self))
                return
            }

            enrollment.completed = true
            if enrollment.objectState != .new, enrollment.objectState != .deleted {
                enrollment.objectState = .modified
            }
            promise.complete(context.saveWithResult())
        }

        return promise.future
    }
}
