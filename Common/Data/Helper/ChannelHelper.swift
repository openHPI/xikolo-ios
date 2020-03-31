//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures
import CoreData
import Foundation
import Stockpile

public enum ChannelHelper {

    @discardableResult public static func syncAllChannels() -> Future<SyncMultipleResult, XikoloError> {
        var query = MultipleResourcesQuery(type: Channel.self)
        query.include("courses")
        return XikoloSyncEngine().synchronize(withFetchRequest: Channel.fetchRequest(), withQuery: query)
    }

    @discardableResult public static func syncChannel(_ channel: Channel) -> Future<SyncSingleResult, XikoloError> {
        var query = SingleResourceQuery(resource: channel)
        query.include("courses")
        return XikoloSyncEngine().synchronize(withFetchRequest: Self.FetchRequest.channel(withId: channel.id), withQuery: query)
    }

}
