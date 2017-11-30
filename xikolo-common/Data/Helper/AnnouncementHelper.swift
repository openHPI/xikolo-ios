//
//  AnnouncementHelper.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 04.07.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import Foundation
import CoreData
import BrightFutures

struct AnnouncementHelper {

    static func syncAllAnnouncements() -> Future<[NSManagedObjectID], XikoloError> {
        let fetchRequest = AnnouncementHelper.FetchRequest.allAnnouncements
        let query = MultipleResourcesQuery(type: Announcement.self)
        return SyncEngine.syncResources(withFetchRequest: fetchRequest, withQuery: query).onComplete {_ in
            self.updateUnreadAnnouncementsBadge()
        }
    }

    static func markAsVisited(_ announcement: Announcement) -> Future<Void, XikoloError> {
        guard !announcement.visited else {
            return Future(value: ())
        }

        let promise = Promise<Void, XikoloError>()

        CoreDataHelper.persistentContainer.performBackgroundTask { context in
            let announcement = context.object(with: announcement.objectID) as Announcement
            announcement.visited = true
            announcement.objectState = .modified
            let saveResult = context.saveWithResult()
            self.updateUnreadAnnouncementsBadge()
            promise.complete(saveResult)
        }

        return promise.future
    }

    private static func updateUnreadAnnouncementsBadge() {
        DispatchQueue.main.async {
            guard let rootViewController = AppDelegate.instance().window?.rootViewController as? UITabBarController else {
                print("Warning: root view controller is not TabBarController")
                return
            }

            guard let tabItem = rootViewController.tabBar.items?[safe: 2] else {
                print("Warning: Failed to retrieve tab item for announcements")
                return
            }

            guard UserProfileHelper.isLoggedIn() else {
                tabItem.badgeValue = nil
                return
            }

            CoreDataHelper.persistentContainer.performBackgroundTask { context in
                let fetchRequest = AnnouncementHelper.FetchRequest.unreadAnnouncements
                do {
                    let count = try context.count(for: fetchRequest)
                    let badgeValue = count > 0 ? String(describing: count) : nil
                    DispatchQueue.main.async {
                        tabItem.badgeValue = badgeValue
                    }
                } catch {
                    print("Warning: Failed to retrieve unread announcement count")
                }
            }
        }

    }

}
