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
            let dateSort = NSSortDescriptor(key: "published_at", ascending: false)
            request.sortDescriptors = [dateSort]
            return request
        }

    }

}
