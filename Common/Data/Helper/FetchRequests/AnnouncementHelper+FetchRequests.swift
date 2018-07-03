//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import CoreData

extension AnnouncementHelper {

    public struct FetchRequest {

        public static var allAnnouncements: NSFetchRequest<Announcement> {
            let request: NSFetchRequest<Announcement> = Announcement.fetchRequest()
            let dateSort = NSSortDescriptor(key: "publishedAt", ascending: false)
            request.sortDescriptors = [dateSort]
            return request
        }

        public static var unreadAnnouncements: NSFetchRequest<Announcement> {
            let request: NSFetchRequest<Announcement> = Announcement.fetchRequest()
            request.predicate = NSPredicate(format: "visited = %@", NSNumber(value: false))
            return request
        }

        public static func announcements(forCourse course: Course) -> NSFetchRequest<Announcement> {
            let request: NSFetchRequest<Announcement> = AnnouncementHelper.FetchRequest.allAnnouncements
            request.predicate = NSPredicate(format: "course = %@", course)
            return request
        }

    }

}
