//
//  PlatformEventHelper.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 07.09.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import Foundation
import CoreData
import BrightFutures

struct PlatformEventHelper {

    @discardableResult static func syncPlatformEvents(forCourse course: Course) -> Future<SyncEngine.SyncMultipleResult, XikoloError> {
        let fetchRequest = PlatformEventHelper.FetchRequest.platformEvents(forCourse: course)
        var query = MultipleResourcesQuery(type: PlatformEvent.self)
        query.addFilter(forKey: "course", withValue: course.id)
        return SyncHelper.syncResources(withFetchRequest: fetchRequest, withQuery: query)
    }
    
}
