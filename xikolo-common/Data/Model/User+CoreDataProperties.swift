//
//  User+CoreDataProperties.swift
//  
//
//  Created by Bjarne Sievers on 22.03.17.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData
import UIKit


extension User {

    @NSManaged var id: String?
    @NSManaged var name: String?
    @NSManaged var avatar_url: URL?
    @NSManaged var profile: UserProfile?

}
