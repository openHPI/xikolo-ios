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

    static func syncMe() -> Future<User, XikoloError> {
        guard let userId = UserProfileHelper.userId else { return Future(error: .userNotLoggedIn) }
        let fetchRequest = UserHelper.FetchRequest.user(withId: userId)
        var query = SingleResourceQuery(type: User.self, id: "me")
        query.include("profile")
        return SyncEngine.syncResource(withFetchRequest: fetchRequest, withQuery: query)
    }

//    static func getMe() -> Future<User, XikoloError> {
//        guard let userId = UserProfileHelper.userId else { return Future(error: .userNotLoggedIn) }
//        return self.getUser(withId: userId)
//    }
//
//    private static func getUser(withId id: String) -> Future<User, XikoloError> {
//        let request: NSFetchRequest<User> = User.fetchRequest()
//        request.predicate = NSPredicate(format: "id == %@", id)
//        request.fetchLimit = 1
//        do {
//            let users = try CoreDataHelper.executeFetchRequest(request)
//            return users.first
//        } catch {
//            return nil
//        }
//    }

}
