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

    static func markAsVisited(announcement: Announcement) -> Future<Void, XikoloError> {
        announcement.visited = true
        return SyncEngine.saveResource(announcement).onSuccess { _ in
            self.updateUnreadAnnouncementsBadge()
        }
    }

    private static func updateUnreadAnnouncementsBadge() {
        guard let rootViewController = AppDelegate.instance().window?.rootViewController as? UITabBarController else {
            print("Warning: root view controller is not TabBarController")
            return
        }

        guard let tabItem = rootViewController.tabBar.items?[safe: 2] else {
            print("Warning: Failed to retrieve tab item for announcements")
            return
        }

        CoreDataHelper.persistentContainer.performBackgroundTask { context in
            let fetchRequest = AnnouncementHelper.FetchRequest.unreadAnnouncements
            do {
                let count = try context.count(for: fetchRequest)
                let badgeValue = count > 0 ? String(describing: count) : nil
                tabItem.badgeValue = badgeValue
            } catch {
                print("Warning: Failed to retrieve unread announcement count")
            }
        }
    }

}
