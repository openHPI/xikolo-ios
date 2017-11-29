//
//  UserHelper+FetchRequests.swift
//  xikolo-ios
//
//  Created by Max Bothe on 16.11.17.
//  Copyright © 2017 HPI. All rights reserved.
//

import CoreData

extension UserHelper {

    struct FetchRequest {

        static func user(withId userId: String) -> NSFetchRequest<User> {
            let request: NSFetchRequest<User> = User.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", userId)
            request.fetchLimit = 1
            return request
        }
    }
}
