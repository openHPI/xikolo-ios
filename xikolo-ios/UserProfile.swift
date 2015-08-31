//
//  User.swift
//  xikolo-ios
//
//  Created by Jonas Müller on 08.07.15.
//  Copyright © 2015 HPI. All rights reserved.
//

import Foundation
import SwiftyJSON
import Realm

public class UserProfile: RLMObject {
    
    static let preferenceId = "id"
    static let preferenceFirstName = "first_name"
    static let preferenceLastName = "last_name"
    static let preferenceEmail = "email"
    static let preferenceVisual = "visual"
    static let preferenceToken = "token"
    static let preferenceLanguage = "language"
    
    // To identify the user profile in Realm and prevent the creation of multiple user profiles in the database
    public static let USER_PROFILE_IDENTIFIER = "user_profile_identifier"
    
    public var id : String = ""
    public var firstName : String = ""
    public var lastName : String = ""
    public var email : String = ""
    public var visual : String = ""
    public var language : String = ""
    
    public var token : String = ""
    
    override init() {
        super.init()
    }
    
    init(id: String, firstName: String, lastName: String, email: String, visual: String, token: String, language: String) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.visual = visual
        self.token = token
        self.language = language
        super.init()
    }
    
    init(json: JSON) {
        
        // ID
        if let obj = json["id"].string {
            self.id = obj
        } else {
            // Shouldn't be executed if type is right
            // TODO: Handle if this is ever called
        }
        
        // First name
        if let obj = json["first_name"].string {
            self.firstName = obj
        } else {
            // Shouldn't be executed if type is right
            // TODO: Handle if this is ever called
        }
        
        // Last Name
        if let obj = json["last_name"].string {
            self.lastName = obj
        } else {
            // Shouldn't be executed if type is right
            // TODO: Handle if this is ever called
        }
        
        // Email
        if let obj = json["email"].string {
            self.email = obj
        } else {
            // Shouldn't be executed if type is right
            // TODO: Handle if this is ever called
        }
        
        // Visual
        if let obj = json["user_visual"].string {
            self.visual = obj
        } else {
            // Shouldn't be executed if type is right
            // TODO: Handle if this is ever called
        }
        
        // Language
        if let obj = json["language"].string {
            self.language = obj
        } else {
            // Shouldn't be executed if type is right
            // TODO: Handle if this is ever called
        }
        
        super.init()
    }
    
    static func getSavedUser()->UserProfile {
        
        let id = NSUserDefaults.standardUserDefaults().stringForKey(preferenceId) ?? ""
        let firstName = NSUserDefaults.standardUserDefaults().stringForKey(preferenceFirstName) ?? ""
        let lastName = NSUserDefaults.standardUserDefaults().stringForKey(preferenceLastName) ?? ""
        let email = NSUserDefaults.standardUserDefaults().stringForKey(preferenceEmail) ?? ""
        let visual = NSUserDefaults.standardUserDefaults().stringForKey(preferenceVisual) ?? ""
        let token = getToken()
        let language = NSUserDefaults.standardUserDefaults().stringForKey(preferenceLanguage) ?? ""
        
        return UserProfile(id: id, firstName: firstName, lastName: lastName, email: email, visual: visual, token: token, language: language)
    }
    
    static func save(user: UserProfile) {
        NSUserDefaults.standardUserDefaults().setObject(user.id, forKey: preferenceId)
        NSUserDefaults.standardUserDefaults().setObject(user.firstName, forKey: preferenceFirstName)
        NSUserDefaults.standardUserDefaults().setObject(user.lastName, forKey: preferenceLastName)
        NSUserDefaults.standardUserDefaults().setObject(user.email, forKey: preferenceEmail)
        NSUserDefaults.standardUserDefaults().setObject(user.visual, forKey: preferenceVisual)
        NSUserDefaults.standardUserDefaults().setObject(user.token, forKey: preferenceToken)
    }
    
    static func isLoggedIn()->Bool {
        return !(NSUserDefaults.standardUserDefaults().stringForKey(preferenceToken) ?? "").isEmpty ?? false
    }
    
    static func getToken() -> String {
        return NSUserDefaults.standardUserDefaults().stringForKey(preferenceToken) ?? ""
    }
    
}
