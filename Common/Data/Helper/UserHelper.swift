//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures
import CoreData
import SyncEngine

public struct UserHelper {

    @discardableResult public static func syncMe() -> Future<SyncSingleResult, XikoloError> {
        let fetchRequest = UserHelper.FetchRequest.user(withId: UserProfileHelper.shared.userId ?? "")
        var query = SingleResourceQuery(type: User.self, id: "me")
        query.include("profile")

        let engine = XikoloSyncEngine()
        return engine.syncResource(withFetchRequest: fetchRequest, withQuery: query)
    }

}
