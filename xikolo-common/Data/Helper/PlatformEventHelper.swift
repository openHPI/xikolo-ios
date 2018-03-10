//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
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
