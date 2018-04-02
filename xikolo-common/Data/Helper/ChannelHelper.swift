//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures

struct ChannelHelper {

    @discardableResult static func syncAllChannels() -> Future<SyncEngine.SyncMultipleResult, XikoloError> {
        let fetchRequest = ChannelHelper.FetchRequest.allChannels
        var query = MultipleResourcesQuery(type: Channel.self)
        return SyncHelper.syncResources(withFetchRequest: fetchRequest, withQuery: query)
    }
    
}
