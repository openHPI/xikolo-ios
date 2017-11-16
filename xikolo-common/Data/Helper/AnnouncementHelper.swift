//
//  AnnouncementHelper.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 04.07.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import Foundation
import BrightFutures

struct AnnouncementHelper {

    static func syncAllAnnouncements() -> Future<[Announcement], XikoloError> {
        let fetchRequest = AnnouncementHelper.FetchRequest.allAnnouncements
        let query = MultipleResourcesQuery(type: Announcement.self)
        return SyncEngine.syncResources(withFetchRequest: fetchRequest, withQuery: query)
    }

}
