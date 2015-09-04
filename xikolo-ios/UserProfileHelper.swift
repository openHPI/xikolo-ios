//
//  User.swift
//  xikolo-ios
//
//  Created by Jonas Müller on 08.07.15.
//  Copyright © 2015 HPI. All rights reserved.
//

import Foundation

public class UserProfileHelper: NSObject {
    
    static let preferenceId = "id"
    static let preferenceFirstName = "first_name"
    static let preferenceLastName = "last_name"
    static let preferenceEmail = "email"
    static let preferenceVisual = "visual"
    static let preferenceToken = "token"
    static let preferenceLanguage = "language"
    
    // To identify the user profile in Realm and prevent the creation of multiple user profiles in the database
    public static let USER_PROFILE_IDENTIFIER = "user_profile_identifier"
    
    static private let prefs = NSUserDefaults.standardUserDefaults()
    
    static func login(email: String, password: String, success:(Bool) -> Void) {
        
        let authenticateUrl = NSURL(string: Routes.API_URL)
        let objectManager = RKObjectManager(baseURL: authenticateUrl)
        
        AFNetworkActivityIndicatorManager.sharedManager().enabled = true
        
        let userMapping = RKObjectMapping(forClass: UserProfile.self)
        userMapping.addAttributeMappingsFromDictionary(["token":"token"])
        
        let responseDescriptor = RKResponseDescriptor(mapping: userMapping, method: RKRequestMethod.POST, pathPattern: nil, keyPath: nil, statusCodes: RKStatusCodeIndexSetForClass(RKStatusCodeClass.Successful))
        
        objectManager.setAcceptHeaderWithMIMEType(RKMIMETypeJSON)
        objectManager.HTTPClient.setDefaultHeader(Routes.HTTP_ACCEPT_HEADER, value: Routes.HTTP_ACCEPT_HEADER_VALUE)
        objectManager.addResponseDescriptor(responseDescriptor)
        
        objectManager.postObject("", path: "authenticate", parameters: [Routes.HTTP_PARAM_EMAIL:email, Routes.HTTP_PARAM_PASSWORD:password], success: { operation, mappingResult in
            
            print("Login successful")
            
            let user = mappingResult.firstObject as! UserProfile
            self.saveToken(user.token)
            
            success(true)
            
            }, failure: { operation, error in
                print("Login error ")
                // TODO Notify about failed login
                if(operation.HTTPRequestOperation.response.statusCode == 401) {
                    // Error 401 Unauthorized
                    print("HTTP Error 401 Unauthorized")
                }
                
                success(false)
        })
    }
    
    static func logout() {
        prefs.removePersistentDomainForName(NSBundle.mainBundle().bundleIdentifier!)
        prefs.synchronize()
        // TODO Clear Realm Database
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
    
    static func update(user: UserProfile) {
        user.token = getToken()
        save(user)
    }
    
    static func isLoggedIn()->Bool {
        return !(getToken().isEmpty ?? true)
    }
    
    static func getToken() -> String {
        let token = prefs.stringForKey(preferenceToken) ?? ""
        return token
    }
    
    static func saveToken(token: String) {
        prefs.setObject(token, forKey: preferenceToken)
        prefs.synchronize()
    }
    
    
    
}
