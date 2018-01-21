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

    @discardableResult static func syncAllPlatformEvents() -> Future<SyncEngine.SyncMultipleResult, XikoloError> {
        let fetchRequest = PlatformEventHelper.FetchRequest.allPlatformEvents
        let query = MultipleResourcesQuery(type: PlatformEvent.self)
        return SyncHelper.syncResources(withFetchRequest: fetchRequest, withQuery: query)
    }
    
}
