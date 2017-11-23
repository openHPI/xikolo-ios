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
        let query = MultipleResourcesQuery(type: Enrollment.self)
        return SyncEngine.syncResources(withFetchRequest: EnrollmentHelper.FetchRequest.allEnrollements, withQuery: query)
    }

    static func createEnrollment(for course: Course) -> Future<Void, XikoloError> {
        let promise = Promise<Void, XikoloError>()

        CoreDataHelper.persistentContainer.performBackgroundTask { context in
            let enrollment = Enrollment(forCourse: course, inContext: context)

            context.saveWithResult().flatMap { _ in
                SyncEngine.saveResource(enrollment)
            }.onSuccess {
                NotificationCenter.default.post(name: NotificationKeys.createdEnrollmentKey, object: nil)
            }.onComplete { result in
                promise.complete(result)
            }
        }

        return promise.future
    }

    static func delete(_ enrollment: Enrollment) -> Future<Void, XikoloError> {
        // TODO: delete after pushed to server but keep deleted state in local database
        return SyncEngine.deleteResource(enrollment).onSuccess {
            CoreDataHelper.persistentContainer.performBackgroundTask { context in
                let enrollment = context.object(with: enrollment.objectID) as Enrollment
                context.delete(enrollment)

                try? context.save()
            }

            NotificationCenter.default.post(name: NotificationKeys.deletedEnrollmentKey, object: enrollment)
        }
    }

    static func markAsCompleted(_ course: Course) -> Future<Void, XikoloError> {

        guard let enrollment = course.enrollment else {
            return Future(error: .totallyUnknownError) // TODO: better error
        }

        let promise = Promise<Void, XikoloError>()

        CoreDataHelper.persistentContainer.performBackgroundTask { context in
            let enrollment = context.object(with: enrollment.objectID) as Enrollment
            enrollment.completed = true

            context.saveWithResult().flatMap { _ in
                SyncEngine.saveResource(enrollment)
            }.onComplete { result in
                promise.complete(result)
            }
        }

        return promise.future
    }
}
