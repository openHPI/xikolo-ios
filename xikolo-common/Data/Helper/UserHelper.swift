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

    static func getUsersRequest() -> NSFetchRequest<NSFetchRequestResult> {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        return request
    }

    static func syncMe() -> Future<User, XikoloError> {
        return UserProvider.getMe().flatMap { spineUser -> Future<User, XikoloError> in
            let request = getUsersRequest()
            return SpineModelHelper.syncObjectsFuture(request, spineObjects: [spineUser], inject: nil, save: true).map({ (basemodels) -> User in
                return basemodels[0] as! User
            })
        }
    }

    static func getByID(_ id: String) throws -> User? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        request.predicate = NSPredicate(format: "id == %@", id)
        request.fetchLimit = 1
        let users = try CoreDataHelper.executeFetchRequest(request) as! [User]
        if users.isEmpty {
            return nil
        }
        return users[0]
    }

    static func getMe() throws -> User? {
        guard let id = UserProfileHelper.getUserId() else { return nil }
        return try getByID(id) 
    }

}
