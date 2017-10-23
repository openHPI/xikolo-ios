//
//  AnnouncementHelper.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 04.07.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import BrightFutures
import CoreData

class AnnouncementHelper {

    static func getRequest() -> NSFetchRequest<Announcement> {
        let request: NSFetchRequest<Announcement> = Announcement.fetchRequest()
        let dateSort = NSSortDescriptor(key: "published_at", ascending: false)
        request.sortDescriptors = [dateSort]
        return request
    }

    static func syncAnnouncements() -> Future<[Announcement], XikoloError> {
        return AnnouncementProvider.getAnnouncements().flatMap { spineAnnouncements -> Future<[Announcement], XikoloError> in
            let request = getRequest()
            return SpineModelHelper.syncObjectsFuture(request, spineObjects: spineAnnouncements, inject: nil, save: true)
        }
    }

}
