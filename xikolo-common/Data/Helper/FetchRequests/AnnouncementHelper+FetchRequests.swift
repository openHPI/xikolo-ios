//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import CoreData

extension AnnouncementHelper {

    struct FetchRequest {

        static var allAnnouncements: NSFetchRequest<Announcement> {
            let request: NSFetchRequest<Announcement> = Announcement.fetchRequest()
            let dateSort = NSSortDescriptor(key: "publishedAt", ascending: false)
            request.sortDescriptors = [dateSort]
            return request
        }

        static var unreadAnnouncements: NSFetchRequest<Announcement> {
            let request: NSFetchRequest<Announcement> = Announcement.fetchRequest()
            request.predicate = NSPredicate(format: "visited = %@", NSNumber(booleanLiteral: false))
            return request
        }

        static func announcements(forCourse course: Course) -> NSFetchRequest<Announcement> {
            let request: NSFetchRequest<Announcement> = AnnouncementHelper.FetchRequest.allAnnouncements
            request.predicate = NSPredicate(format: "course = %@", course)
            return request
        }

    }

}
