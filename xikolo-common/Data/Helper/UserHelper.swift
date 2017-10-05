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

    static func getUsersRequest() -> NSFetchRequest<User> {
        let request: NSFetchRequest<User> = User.fetchRequest()
        return request
    }

    static func syncMe() -> Future<User, XikoloError> {
        return UserProvider.getMe().flatMap { spineUser -> Future<User, XikoloError> in
            let request = getUsersRequest()
            return SpineModelHelper.syncObjectsFuture(request, spineObjects: [spineUser], inject: nil, save: true).map({ (cdUsers) -> User in
                return cdUsers[0]
            })
        }
    }

    static func getUser(byId id: String) -> User? {
        let request: NSFetchRequest<User> = User.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        request.fetchLimit = 1
        do {
            let users = try CoreDataHelper.executeFetchRequest(request)
            return users.first
        } catch {
            return nil
        }
    }

    static func getMe() -> User? {
        guard let id = UserProfileHelper.userId else { return nil }
        return self.getUser(byId: id)
    }

}
