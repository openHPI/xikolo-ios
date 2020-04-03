//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures
import CoreData
import Stockpile

public enum UserHelper {

    @discardableResult public static func syncMe() -> Future<SyncSingleResult, XikoloError> {
        let fetchRequest = Self.FetchRequest.user(withId: UserProfileHelper.shared.userId ?? "")
        var query = SingleResourceQuery(type: User.self, id: "me")
        query.include("profile")
        return XikoloSyncEngine().synchronize(withFetchRequest: fetchRequest, withQuery: query)
    }

}
