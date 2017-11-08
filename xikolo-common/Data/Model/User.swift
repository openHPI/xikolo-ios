//
//  User.swift
//  
//
//  Created by Bjarne Sievers on 22.03.17.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData
import BrightFutures
import Spine

@objcMembers
class User: NSManagedObject {

    @NSManaged var id: String
    @NSManaged var name: String?
    @NSManaged var avatarURLString: String?
    @NSManaged var profile: UserProfile?

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User");
    }

    var avatarURL: URL? {
        get {
            guard let value = self.avatarURLString else { return nil }
            return URL(string: value)
        }
        set {
            self.avatarURLString = newValue?.absoluteString
        }
    }
}

extension User : Pullable {

    static var type: String {
        return "users"
    }

    func update(withObject object: ResourceData, including includes: [ResourceData]?, inContext context: NSManagedObjectContext) throws {
        let attributes = try object.value(for: "attributes") as JSON
        self.name = try attributes.value(for: "name")
        self.avatarURLString = try attributes.value(for: "avatar_url")

        let relationships = try object.value(for: "relationships") as JSON
        try self.updateRelationship(forKeyPath: \User.profile, forKey: "profile", fromObject: relationships, including: includes, inContext: context)
    }

}

//@objcMembers
//class UserSpine : BaseModelSpine {
//
//    var name: String?
//    var avatar_url: URL?
//
//    var profile: UserProfile?
//
//    override class var cdType: BaseModel.Type {
//        return User.self
//    }
//
//    override class var resourceType: ResourceType {
//        return "users"
//    }
//
//    override class var fields: [Field] {
//        return fieldsFromDictionary([
//            "name": Attribute().readOnly(),
//            "avatar_url": URLAttribute(baseURL: URL(string: Brand.BaseURL)!),
//            "profile": ToOneRelationship(UserProfileSpine.self),
//        ])
//    }
//
//}

