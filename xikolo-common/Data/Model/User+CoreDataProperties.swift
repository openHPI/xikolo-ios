//
//  User+CoreDataProperties.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 22.03.17.
//  Copyright © 2017 HPI. All rights reserved.
//

import Foundation
import CoreData
import UIKit


extension User {

    @NSManaged var id: String?
    @NSManaged var name: String?
    @NSManaged var avatar_url: URL?
    @NSManaged var profile: UserProfile?

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User");
    }

}
