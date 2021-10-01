//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures
import CoreData
import Foundation
import Stockpile

public enum AnnouncementHelper {

    @discardableResult public static func syncAllAnnouncements() -> Future<SyncMultipleResult, XikoloError> {
        var query = MultipleResourcesQuery(type: Announcement.self)
        query.addFilter(forKey: "global", withValue: "true")
        return XikoloSyncEngine().synchronize(withFetchRequest: Announcement.fetchRequest(), withQuery: query)
    }

    @discardableResult public static func syncAnnouncements(for course: Course) -> Future<SyncMultipleResult, XikoloError> {
        let fetchRequest = Self.FetchRequest.announcements(forCourse: course)
        var query = MultipleResourcesQuery(type: Announcement.self)
        query.addFilter(forKey: "course", withValue: course.id)
        return XikoloSyncEngine().synchronize(withFetchRequest: fetchRequest, withQuery: query)
    }

    @discardableResult public static func markAllAsVisited() -> Future<Void, XikoloError> {
        guard UserProfileHelper.shared.isLoggedIn else {
            return Future(value: ())
        }

        let promise = Promise<Void, XikoloError>()

        CoreDataHelper.persistentContainer.performBackgroundTask { context in
            let request = NSBatchUpdateRequest(entity: Announcement.entity())
            request.resultType = .updatedObjectIDsResultType
            request.predicate = NSPredicate(format: "visited == %@", NSNumber(value: false))
            request.propertiesToUpdate = [
                "visited": true,
                "objectStateValue": ObjectState.modified.rawValue,
            ]

            let result = Result<[NSManagedObjectID], Error> {
                let updateResult = try context.execute(request) as? NSBatchUpdateResult
                return (updateResult?.result as? [NSManagedObjectID]) ?? []
            }.mapError { error in
                return XikoloError.coreData(error)
            }.map { objectIDs in
                let changes = [NSUpdatedObjectsKey: objectIDs]
                NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [CoreDataHelper.viewContext])
            }

            promise.complete(result)
        }

        return promise.future
    }

    @discardableResult public static func markAsVisited(_ item: Announcement) -> Future<Void, XikoloError> {
        guard UserProfileHelper.shared.isLoggedIn && !item.visited else {
            return Future(value: ())
        }

        let promise = Promise<Void, XikoloError>()

        CoreDataHelper.persistentContainer.performBackgroundTask { context in
            guard let announcement = context.existingTypedObject(with: item.objectID) as? Announcement else {
                promise.failure(.missingResource(ofType: Announcement.self))
                return
            }

            announcement.visited = true
            announcement.objectState = .modified
            promise.complete(context.saveWithResult())
        }

        return promise.future
    }

}
