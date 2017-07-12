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

    static func getByID(_ id: String) throws -> User? {
        let request: NSFetchRequest<User> = User.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        request.fetchLimit = 1
        let users = try CoreDataHelper.executeFetchRequest(request)
        return users.first
    }

    static func getMe() throws -> User? {
        guard let id = UserProfileHelper.getUserId() else { return nil }
        return try getByID(id) 
    }

}
