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
    
    static private let prefs = NSUserDefaults.standardUserDefaults()
    
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
        
        let id = prefs.stringForKey(preferenceId) ?? ""
        let firstName = prefs.stringForKey(preferenceFirstName) ?? ""
        let lastName = prefs.stringForKey(preferenceLastName) ?? ""
        let email = prefs.stringForKey(preferenceEmail) ?? ""
        let visual = prefs.stringForKey(preferenceVisual) ?? ""
        let token = getToken()
        let language = prefs.stringForKey(preferenceLanguage) ?? ""
        
        let user = UserProfile(id: id, firstName: firstName, lastName: lastName, email: email, visual: visual, token: token, language: language)
        
        return user
    }
    
    static func save(user: UserProfile) {
        prefs.setObject(user.id, forKey: preferenceId)
        prefs.setObject(user.firstName, forKey: preferenceFirstName)
        prefs.setObject(user.lastName, forKey: preferenceLastName)
        prefs.setObject(user.email, forKey: preferenceEmail)
        prefs.setObject(user.visual, forKey: preferenceVisual)
        prefs.setObject(user.token, forKey: preferenceToken)
        prefs.setObject(user.language, forKey: preferenceLanguage)
        prefs.synchronize()
    }
    
    static func isLoggedIn()->Bool {
        return !(getToken().isEmpty ?? true)
    }
    
    static func getToken() -> String {
        return prefs.stringForKey(preferenceToken) ?? ""
    }
    
}
