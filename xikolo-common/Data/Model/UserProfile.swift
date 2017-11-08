//
//  UserProfile.swift
//  
//
//  Created by Bjarne Sievers on 22.03.17.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData
import Spine

@objcMembers
class UserProfile: NSManagedObject {

    @NSManaged var id: String
    @NSManaged var displayName: String?
    @NSManaged var firstName: String?
    @NSManaged var lastName: String?
    @NSManaged var email: String?
    @NSManaged var user: User?

    var fullName: String? {
        let components = [self.firstName, self.lastName].flatMap{ $0 }
        return components.count > 0 ? components.joined(separator: " ") : nil
    }

}

extension UserProfile : Pullable {

    static var type: String {
        return "user-profile"
    }

    func update(withObject object: ResourceData, including includes: [ResourceData]?, inContext context: NSManagedObjectContext) throws {
        let attributes = try object.value(for: "attributes") as JSON
        self.displayName = try attributes.value(for: "display_name")
        self.firstName = try attributes.value(for: "first_name")
        self.lastName = try attributes.value(for: "last_name")
        self.email = try attributes.value(for: "email")
    }

}

//@objcMembers
//class UserProfileSpine : BaseModelSpine {
//
//    var display_name: String?
//    var first_name: String?
//    var last_name: String?
//    var email: String?
//    var user: User?
//
//    override class var cdType: BaseModel.Type {
//        return UserProfile.self
//    }
//
//    override class var resourceType: ResourceType {
//        return "user-profile"
//    }
//
//    override class var fields: [Field] {
//        return fieldsFromDictionary([
//            "display_name": Attribute(),
//            "first_name": Attribute(),
//            "last_name": Attribute(),
//            "email": Attribute(),
//            "user": ToOneRelationship(UserSpine.self),
//        ])
//    }
//
//}

