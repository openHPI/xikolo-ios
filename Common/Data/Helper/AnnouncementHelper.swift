//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures
import Foundation

struct AnnouncementHelper {

    static let shared = AnnouncementHelper()

    var delegate: AnnouncementHelperDelegate?

    private init() {}

    @discardableResult func syncAllAnnouncements() -> Future<SyncEngine.SyncMultipleResult, XikoloError> {
        let fetchRequest = AnnouncementHelper.FetchRequest.allAnnouncements
        var query = MultipleResourcesQuery(type: Announcement.self)
        query.addFilter(forKey: "global", withValue: "true")
        return SyncEngine.shared.syncResources(withFetchRequest: fetchRequest, withQuery: query).onComplete { _ in
            self.delegate?.updateUnreadAnnouncementsBadge()
        }
    }

    @discardableResult func syncAnnouncements(for course: Course) -> Future<SyncEngine.SyncMultipleResult, XikoloError> {
        let fetchRequest = AnnouncementHelper.FetchRequest.allAnnouncements
        var query = MultipleResourcesQuery(type: Announcement.self)
        query.addFilter(forKey: "course", withValue: course.id)
        return SyncEngine.shared.syncResources(withFetchRequest: fetchRequest, withQuery: query, deleteNotExistingResources: false).onComplete { _ in
            self.delegate?.updateUnreadAnnouncementsBadge()
        }
    }

    @discardableResult func markAsVisited(_ item: Announcement) -> Future<Void, XikoloError> {
        guard UserProfileHelper.isLoggedIn && !item.visited else {
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

protocol AnnouncementHelperDelegate {

    func updateUnreadAnnouncementsBadge()

}
