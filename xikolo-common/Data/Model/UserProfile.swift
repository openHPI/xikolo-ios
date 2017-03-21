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

class UserProfile: BaseModel {


}

class UserProfileSpine : BaseModelSpine {

    var display_name: String?
    var first_name: String?
    var last_name: String?
    var email: String?
    var user: User?

    override class var cdType: BaseModel.Type {
        return UserProfile.self
    }

    override class var resourceType: ResourceType {
        return "user-profile"
    }

    override class var fields: [Field] {
        return fieldsFromDictionary([
            "display_name": Attribute(),
            "first_name": Attribute(),
            "last_name": Attribute(),
            "email": Attribute(),
            "user": ToOneRelationship(UserSpine.self),
        ])
    }
    
}
