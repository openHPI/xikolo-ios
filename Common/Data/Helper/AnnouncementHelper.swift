//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures
import CoreData
import Foundation
import Result
import SyncEngine

public class AnnouncementHelper {

    public static let shared = AnnouncementHelper()

    public weak var delegate: AnnouncementHelperDelegate?

    private init() {}

    @discardableResult public func syncAllAnnouncements() -> Future<SyncEngine.SyncMultipleResult, XikoloError> {
        let fetchRequest = AnnouncementHelper.FetchRequest.allAnnouncements
        var query = MultipleResourcesQuery(type: Announcement.self)
        query.addFilter(forKey: "global", withValue: "true")
        return SyncEngine.syncResourcesXikolo(withFetchRequest: fetchRequest, withQuery: query).onComplete { _ in
            self.delegate?.updateUnreadAnnouncementsBadge()
        }
    }

    @discardableResult public func syncAnnouncements(for course: Course) -> Future<SyncEngine.SyncMultipleResult, XikoloError> {
        let fetchRequest = AnnouncementHelper.FetchRequest.allAnnouncements
        var query = MultipleResourcesQuery(type: Announcement.self)
        query.addFilter(forKey: "course", withValue: course.id)
        return SyncEngine.syncResourcesXikolo(withFetchRequest: fetchRequest, withQuery: query, deleteNotExistingResources: false).onComplete { _ in
            self.delegate?.updateUnreadAnnouncementsBadge()
        }
    }

    @discardableResult public func markAllAsVisited() -> Future<Void, XikoloError> {
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

            let result = Result<[NSManagedObjectID], AnyError> {
                let updateResult = try context.execute(request) as? NSBatchUpdateResult
                return (updateResult?.result as? [NSManagedObjectID]) ?? []
            }.mapError { error in
                return XikoloError.coreData(error.error)
            }.map { objectIDs in
                let changes = [NSUpdatedObjectsKey: objectIDs]
                NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [CoreDataHelper.viewContext])
            }

            promise.complete(result)
            self.delegate?.updateUnreadAnnouncementsBadge()
        }

        return promise.future
    }

    @discardableResult public func markAsVisited(_ item: Announcement) -> Future<Void, XikoloError> {
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
            self.delegate?.updateUnreadAnnouncementsBadge()
        }

        return promise.future
    }

}

public protocol AnnouncementHelperDelegate: AnyObject {

    func updateUnreadAnnouncementsBadge()

}
