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

    @discardableResult static func syncMe() -> Future<SyncEngine.SyncSingleResult, XikoloError> {
        let fetchRequest = UserHelper.FetchRequest.user(withId: UserProfileHelper.userId ?? "")
        var query = SingleResourceQuery(type: User.self, id: "me")
        query.include("profile")
        return SyncHelper.syncResource(withFetchRequest: fetchRequest, withQuery: query)
    }

}
