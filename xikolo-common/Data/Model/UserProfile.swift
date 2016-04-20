//
//  User.swift
//  xikolo-ios
//
//  Created by Jonas Müller on 08.07.15.
//  Copyright © 2015 HPI. All rights reserved.
//

import Alamofire
import Foundation
import ObjectMapper

public class UserProfile: NSObject, NSCoding, Mappable {

    public var id : String = ""
    public var firstName : String = ""
    public var lastName : String = ""
    public var email : String = ""
    public var visual : String = ""
    public var language : String = ""
    
    required public init?(_ map: Map){
    }
    
    public func mapping(map: Map) {
        id <- map["id"]
        firstName <- map["first_name"]
        lastName <- map["last_name"]
        email <- map["email"]
        visual <- map["user_visual"]
        language <- map["language"]
    }
    
    required public init(coder decoder: NSCoder) {
        if let id = decoder.decodeObjectForKey("id") as? String {
            self.id = id
        }
        if let firstName = decoder.decodeObjectForKey("firstName") as? String {
            self.firstName = firstName
        }
        if let lastName = decoder.decodeObjectForKey("lastName") as? String {
            self.lastName = lastName
        }
        if let email = decoder.decodeObjectForKey("email") as? String {
            self.email = email
        }
        if let visual = decoder.decodeObjectForKey("visual") as? String {
            self.visual = visual
        }
        if let language = decoder.decodeObjectForKey("language") as? String {
            self.language = language
        }
    }
    
    public func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(self.id, forKey: "id")
        coder.encodeObject(self.firstName, forKey: "firstName")
        coder.encodeObject(self.lastName, forKey: "lastName")
        coder.encodeObject(self.email, forKey: "email")
        coder.encodeObject(self.visual, forKey: "visual")
        coder.encodeObject(self.language, forKey: "language")
    }

}
