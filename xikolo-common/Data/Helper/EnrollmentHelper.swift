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

//        enrollment.completed = true
//        return SyncEngine.saveResource(enrollment)

        let promise = Promise<Void, XikoloError>()

//        CoreDataHelper.persistentContainer.performBackgroundTask { context in
//            let enrollment = context.object(with: enrollment.objectID) as Enrollment
//            enrollment.completed = true
//            try? context.save()
//            let saveFuture = SyncEngine.saveResource(enrollment)
//            promise.completeWith(saveFuture)
//            Result.init(attempt: { return try? context.save() })
//        }

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

//import BrightFutures
//import CoreData
//
//class EnrollmentHelper {
//
//    static func getEnrollmentsRequest() -> NSFetchRequest<Enrollment> {
//        let request: NSFetchRequest<Enrollment> = Enrollment.fetchRequest()
//        return request
//    }
//
//    static func syncEnrollments() -> Future<[Enrollment], XikoloError> {
//        return EnrollmentProvider.getEnrollments().flatMap { spineEnrollments -> Future<[Enrollment], XikoloError> in
//            let request = getEnrollmentsRequest()
//            return SpineModelHelper.syncObjectsFuture(request, spineObjects: spineEnrollments, inject: nil, save: true)
//        }
//    }
//
//    static func createEnrollment(for course: Course) -> Future<Void, XikoloError> {
//        let promise = Promise<Void, XikoloError>()
//
////        let courseSpine = CourseSpine(course: course)
//        CoreDataHelper.persistentContainer.performBackgroundTask { context in
//            let enrollment = Enrollment(forCourse: course, inContext: context)
//            CoreDataHelper.save(context).flatMap {
//                return SyncEngine.saveResource(enrollment)
//            }.onSuccess {
//                NotificationCenter.default.post(name: NotificationKeys.createdEnrollmentKey, object: nil)
//            }.onComplete { result in
//                promise.complete(result)
//            }
//        }
////        let enrollmentSpine = EnrollmentSpine(course: courseSpine)
////        SpineHelper.save(enrollmentSpine).onSuccess { enrollmentSpine in
////
////            return promise.success(())
////        }.onFailure { xikoloError in
////            return promise.failure(xikoloError)
////        }
//        return promise.future
//    }
//
//    static func delete(_ enrollment: Enrollment) -> Future<Void, XikoloError> {
////        let promise = Promise<Void, XikoloError>()
//
////        let enrollmentSpine = EnrollmentSpine(from: enrollment)
////        SpineHelper.delete(enrollmentSpine).onSuccess { _ in
////            CoreDataHelper.delete(enrollment)
////            NotificationCenter.default.post(name: NotificationKeys.deletedEnrollmentKey, object: enrollment)
////            return promise.success(())
////        }.onFailure { xikoloError in
////            return promise.failure(xikoloError)
////        }
//
//        return SyncEngine.deleteResource(enrollment).onSuccess {
//            CoreDataHelper.delete(enrollment)
//            NotificationCenter.default.post(name: NotificationKeys.deletedEnrollmentKey, object: enrollment)
//        }
//
////        return promise.future
//    }
//
//    static func markAsCompleted(_ course: Course) -> Future<Void, XikoloError> {
//
//        guard let enrollment = course.enrollment else {
//            return Future(error: .totallyUnknownError) // TODO: better error
//        }
//
//        enrollment.completed = true
//        return SyncEngine.saveResource(enrollment)
//
////        let promise = Promise<Void, XikoloError>()
//
////        CoreDataHelper.persistentContainer.performBackgroundTask { context in
//////            course.enrollment?.completed = true
//////            return SpineHelper.save(EnrollmentSpine(from: course.enrollment!))
////            enrollmen
////        }
//
////        return promise.future
//
//    }
//
//}

