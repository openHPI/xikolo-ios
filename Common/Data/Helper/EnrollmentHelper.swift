//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures
import CoreData
import Foundation
import Stockpile

public enum EnrollmentHelper {

    public static func createEnrollment(for course: Course) -> Future<Void, XikoloError> {
        let attributes = ["completed": false]
        let relationships = ["course": course as AnyObject]
        let resourceData = Enrollment.resourceData(attributes: attributes, relationships: relationships)
        return XikoloSyncEngine().createResource(ofType: Enrollment.self, withData: resourceData).asVoid()
    }

    public static func delete(_ enrollment: Enrollment?) -> Future<Void, XikoloError> {
        guard let enrollment = enrollment else {
            return Future(error: .missingResource(ofType: Enrollment.self))
        }

        let promise = Promise<Void, XikoloError>()

        CoreDataHelper.persistentContainer.performBackgroundTask { context in
            context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump

            guard let enrollmentToDelete = context.existingTypedObject(with: enrollment.objectID) as? Enrollment else {
                promise.success(())
                return
            }

            enrollmentToDelete.objectState = .deleted
            let saveResult = context.saveWithResult()

            promise.complete(saveResult)
        }

        return promise.future
    }

    @discardableResult public static func markAsCompleted(_ course: Course) -> Future<Void, XikoloError> {
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

            // workaround to publish course enrollment changes to course (triggers update of course lists)
            if let courseOfEnrollment = context.existingTypedObject(with: course.objectID) as? Course {
                let updatedEnrollment = courseOfEnrollment.enrollment
                courseOfEnrollment.enrollment = updatedEnrollment
            }

            if enrollment.objectState != .new, enrollment.objectState != .deleted {
                enrollment.objectState = .modified
            }

            promise.complete(context.saveWithResult())
        }

        return promise.future
    }

    public static func syncEnrollments() -> Future<SyncMultipleResult, XikoloError> {
        let fetchRequest = Self.FetchRequest.allEnrollments()
        let query = MultipleResourcesQuery(type: Enrollment.self)
        return XikoloSyncEngine().synchronize(withFetchRequest: fetchRequest, withQuery: query)
    }

}
