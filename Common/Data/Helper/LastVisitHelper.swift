//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures
import CoreData
import Foundation
import Stockpile

public enum LastVisitHelper {

    public static func syncLastVisit(forCourse course: Course) -> Future<SyncSingleResult, XikoloError> {
        let fetchRequest = Self.FetchRequest.lastVisit(forCourse: course)
        let query = SingleResourceQuery(type: LastVisit.self, id: course.id)
        return XikoloSyncEngine().synchronize(withFetchRequest: fetchRequest, withQuery: query)
    }

    public static func recordVisit( for item: CourseItem) -> Future<Void, XikoloError> {
        let promise = Promise<Void, XikoloError>()

        CoreDataHelper.persistentContainer.performBackgroundTask { context in
            context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump

            guard let item = context.existingTypedObject(with: item.objectID) as? CourseItem else {
                promise.failure(.missingResource(ofType: CourseItem.self))
                return
            }

            guard let course = item.section?.course else {
                promise.failure(.missingResource(ofType: Course.self))
                return
            }

            let fetchRequest = Self.FetchRequest.lastVisit(forCourse: course)
            guard let lastVisit = context.fetchSingle(fetchRequest).value else {
                promise.failure(.missingResource(ofType: LastVisit.self))
                return
            }

            lastVisit.visitDate = Date()
            lastVisit.item = item
            promise.complete(context.saveWithResult())
        }

        return promise.future
    }

}
