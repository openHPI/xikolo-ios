//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures
import Foundation
import SyncEngine

struct PlatformEventHelper {

    @discardableResult static func syncAllPlatformEvents() -> Future<SyncMultipleResult, XikoloError> {
        let fetchRequest = PlatformEventHelper.FetchRequest.allPlatformEvents
        let query = MultipleResourcesQuery(type: PlatformEvent.self)

        let engine = XikoloSyncEngine()
        return engine.syncResources(withFetchRequest: fetchRequest, withQuery: query).mapError { error -> XikoloError in
            return .synchronization(error)
        }
    }

}
