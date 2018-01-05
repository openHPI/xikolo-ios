//
//  AnnouncementHelper+FetchRequests.swift
//  xikolo-ios
//
//  Created by Max Bothe on 16.11.17.
//  Copyright © 2017 HPI. All rights reserved.
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
            let dateSort = NSSortDescriptor(key: "publishedAt", ascending: false)
            request.sortDescriptors = [dateSort]
            request.predicate = NSPredicate(format: "visited = %@", NSNumber(booleanLiteral: false))
            return request
        }

        static func courseAnnouncements(forCourseId courseId: String) -> NSFetchRequest<Announcement> {
            let request: NSFetchRequest<Announcement> = AnnouncementHelper.FetchRequest.allAnnouncements
            request.predicate = NSPredicate(format: "course.id = %@", courseId)
            return request
        }

    }

}
