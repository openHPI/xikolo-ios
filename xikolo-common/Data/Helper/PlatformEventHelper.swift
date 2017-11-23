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

    static func syncAllPlatformEvents() -> Future<[NSManagedObjectID], XikoloError> {
        let fetchRequest = PlatformEventHelper.FetchRequest.allPlatformEvents
        let query = MultipleResourcesQuery(type: PlatformEvent.self)
        return SyncEngine.syncResources(withFetchRequest: fetchRequest, withQuery: query)
    }
    
}
