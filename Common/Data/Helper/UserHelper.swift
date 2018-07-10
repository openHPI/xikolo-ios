//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures
import CoreData

public struct UserHelper {

    @discardableResult public static func syncMe() -> Future<SyncEngine.SyncSingleResult, XikoloError> {
        let fetchRequest = UserHelper.FetchRequest.user(withId: UserProfileHelper.shared.userId ?? "")
        var query = SingleResourceQuery(type: User.self, id: "me")
        query.include("profile")
        return SyncEngine.shared.syncResource(withFetchRequest: fetchRequest, withQuery: query)
    }

}
