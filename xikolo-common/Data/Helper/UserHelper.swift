//
//  UserHelper.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 28.03.17.
//  Copyright © 2017 HPI. All rights reserved.
//

import BrightFutures
import CoreData

class UserHelper {

    static func syncMe() -> Future<NSManagedObjectID, XikoloError> {
        guard let userId = UserProfileHelper.userId else { return Future(error: .userNotLoggedIn) }
        let fetchRequest = UserHelper.FetchRequest.user(withId: userId)
        var query = SingleResourceQuery(type: User.self, id: "me")
        query.include("profile")
        return SyncEngine.syncResource(withFetchRequest: fetchRequest, withQuery: query)
    }

}
