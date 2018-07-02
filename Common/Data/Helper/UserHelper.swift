//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures
import CoreData

class UserHelper {

    @discardableResult static func syncMe() -> Future<SyncEngine.SyncSingleResult, XikoloError> {
        let fetchRequest = UserHelper.FetchRequest.user(withId: UserProfileHelper.userId ?? "")
        var query = SingleResourceQuery(type: User.self, id: "me")
        query.include("profile")
        return SyncEngine.shared.syncResource(withFetchRequest: fetchRequest, withQuery: query)
    }

}
