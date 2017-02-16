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

open class UserProfile: NSObject, NSCoding, Mappable {

    open var id : String = ""
    open var firstName : String = ""
    open var lastName : String = ""
    open var email : String = ""
    open var visual : String = ""
    open var language : String = ""
    
    required public init?(map: Map){
    }
    
    open func mapping(map: Map) {
        id <- map["id"]
        firstName <- map["first_name"]
        lastName <- map["last_name"]
        email <- map["email"]
        visual <- map["user_visual"]
        language <- map["language"]
    }
    
    required public init(coder decoder: NSCoder) {
        if let id = decoder.decodeObject(forKey: "id") as? String {
            self.id = id
        }
        if let firstName = decoder.decodeObject(forKey: "firstName") as? String {
            self.firstName = firstName
        }
        if let lastName = decoder.decodeObject(forKey: "lastName") as? String {
            self.lastName = lastName
        }
        if let email = decoder.decodeObject(forKey: "email") as? String {
            self.email = email
        }
        if let visual = decoder.decodeObject(forKey: "visual") as? String {
            self.visual = visual
        }
        if let language = decoder.decodeObject(forKey: "language") as? String {
            self.language = language
        }
    }
    
    open func encode(with coder: NSCoder) {
        coder.encode(self.id, forKey: "id")
        coder.encode(self.firstName, forKey: "firstName")
        coder.encode(self.lastName, forKey: "lastName")
        coder.encode(self.email, forKey: "email")
        coder.encode(self.visual, forKey: "visual")
        coder.encode(self.language, forKey: "language")
    }

}
