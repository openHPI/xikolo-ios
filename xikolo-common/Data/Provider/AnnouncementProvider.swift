//
//  AnnouncementProvider.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 04.07.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import BrightFutures
import Foundation
import Spine

class AnnouncementProvider {

    class func getAnnouncements() -> Future<[AnnouncementSpine], XikoloError> {
        var query = Query(resourceType: AnnouncementSpine.self)
        query.addPredicateWithKey("global", value: "true", type: .equalTo)

        return SpineHelper.find(query)
    }

}
