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
class User: BaseModel {
    

}

@objcMembers
class UserSpine : BaseModelSpine {

    var name: String?
    var avatar_url: URL?
    
    var profile: UserProfile?

    override class var cdType: BaseModel.Type {
        return User.self
    }

    override class var resourceType: ResourceType {
        return "users"
    }

    override class var fields: [Field] {
        return fieldsFromDictionary([
            "name": Attribute().readOnly(),
            "avatar_url": URLAttribute(baseURL: URL(string: Brand.BaseURL)!),
            "profile": ToOneRelationship(UserProfileSpine.self),
        ])
    }
    
}
