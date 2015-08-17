//
//  User.swift
//  xikolo-ios
//
//  Created by Jonas Müller on 08.07.15.
//  Copyright © 2015 HPI. All rights reserved.
//

import Foundation

class UserModel: NSObject {
    
    static let preferenceId = "id"
    static let preferenceFirstName = "first_name"
    static let preferenceLastName = "last_name"
    static let preferenceEmail = "email"
    static let preferenceVisual = "visual"
    static let preferenceToken = "token"
    
    static func login(email: String, password: String) {
        
        let authenticateUrl = NSURL(string: Routes.BASE_URL)
        let objectManager = RKObjectManager(baseURL: authenticateUrl)
        
        AFNetworkActivityIndicatorManager.sharedManager().enabled = true
        
        let userMapping = RKObjectMapping(forClass: User.self)
        userMapping.addAttributeMappingsFromDictionary(["token":"token"])
        
        let responseDescriptor = RKResponseDescriptor(mapping: userMapping, method: RKRequestMethod.POST, pathPattern: nil, keyPath: nil, statusCodes: RKStatusCodeIndexSetForClass(RKStatusCodeClass.Successful))
        
        objectManager.setAcceptHeaderWithMIMEType(RKMIMETypeJSON)
        objectManager.HTTPClient.setDefaultHeader(Routes.HTTP_ACCEPT_HEADER, value: Routes.HTTP_ACCEPT_HEADER_VALUE)
        objectManager.addResponseDescriptor(responseDescriptor)
        
        objectManager.postObject("", path: "authenticate", parameters: [Routes.HTTP_PARAM_EMAIL:email, Routes.HTTP_PARAM_PASSWORD:password], success: { operation, mappingResult in
            
            print("Login successful")
            
            let user = mappingResult.firstObject as! User
            saveToken(user.token)
            
            }, failure: { operation, error in
                print("Login error ")
                // TODO Notify about failed login
                if(operation.HTTPRequestOperation.response.statusCode == 401) {
                    // Error 401 Unauthorized
                    print("HTTP Error 401 Unauthorized")
                }
        })
    }
    
    static func getSavedUser()->User {
        
        let id = getID()
        let firstName = getFirstName()
        let lastName = getLastName()
        let email = getEmail()
        let visual = getVisual()
        let token = getToken()
        
        return User(id: id, firstName: firstName, lastName: lastName, email: email, visual: visual, token: token)
    }
    
    static func saveUser(user: User) {
        saveID(user.id)
        saveFirstName(user.firstName)
        saveLastName(user.lastName)
        saveEmail(user.email)
        saveVisual(user.visual)
        saveToken(user.token)
    }
    
    static func isLoggedIn()->Bool {
        // TODO
        return false
    }
    
    // Reading
    
    static func getID()->String {
        return NSUserDefaults.standardUserDefaults().stringForKey(preferenceId) ?? ""
    }
    
    static func getFirstName()->String {
        return NSUserDefaults.standardUserDefaults().stringForKey(preferenceFirstName) ?? ""
    }
    
    static func getLastName()->String {
        return NSUserDefaults.standardUserDefaults().stringForKey(preferenceLastName) ?? ""
    }
    
    static func getEmail()->String {
        return NSUserDefaults.standardUserDefaults().stringForKey(preferenceEmail) ?? ""
    }
    
    static func getVisual()->String {
        return NSUserDefaults.standardUserDefaults().stringForKey(preferenceVisual) ?? ""
    }
    
    static func getToken()->String {
        return NSUserDefaults.standardUserDefaults().stringForKey(preferenceToken) ?? ""
    }
    
    // Saving
    
    static func saveID(id: String) {
        NSUserDefaults.standardUserDefaults().setObject(id, forKey: preferenceId)
    }
    
    static func saveFirstName(firstName: String) {
        NSUserDefaults.standardUserDefaults().setObject(firstName, forKey: preferenceFirstName)
    }
    
    static func saveLastName(lastName: String) {
        NSUserDefaults.standardUserDefaults().setObject(lastName, forKey: preferenceLastName)
    }
    
    static func saveEmail(email: String) {
        NSUserDefaults.standardUserDefaults().setObject(email, forKey: preferenceEmail)
    }
    
    static func saveVisual(visual: String) {
        NSUserDefaults.standardUserDefaults().setObject(visual, forKey: preferenceVisual)
    }
    
    static func saveToken(token: String) {
        NSUserDefaults.standardUserDefaults().setObject(token, forKey: preferenceToken)
    }
    
}
