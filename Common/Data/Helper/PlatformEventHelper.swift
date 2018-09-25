//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures
import Foundation
import SyncEngine

struct PlatformEventHelper {

    @discardableResult static func syncAllPlatformEvents() -> Future<SyncEngine.SyncMultipleResult, XikoloError> {
        let fetchRequest = PlatformEventHelper.FetchRequest.allPlatformEvents
        let query = MultipleResourcesQuery(type: PlatformEvent.self)
        return SyncEngine.syncResourcesXikolo(withFetchRequest: fetchRequest, withQuery: query)
    }

}
