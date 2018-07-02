//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures
import Foundation

struct PlatformEventHelper {

    @discardableResult static func syncAllPlatformEvents() -> Future<SyncEngine.SyncMultipleResult, XikoloError> {
        let fetchRequest = PlatformEventHelper.FetchRequest.allPlatformEvents
        let query = MultipleResourcesQuery(type: PlatformEvent.self)
        return SyncEngine.shared.syncResources(withFetchRequest: fetchRequest, withQuery: query)
    }

}
