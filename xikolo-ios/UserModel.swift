//
//  User.swift
//  xikolo-ios
//
//  Created by Jonas Müller on 08.07.15.
//  Copyright © 2015 HPI. All rights reserved.
//

import Foundation

class UserModel: NSObject {
    
        
    static func login(email: String, password: String, success:(Bool) -> Void) {
        
        let authenticateUrl = NSURL(string: Routes.BASE_URL)
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
            UserProfile.save(user)
            
            print("Token: " + user.token)
            
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
    
    
    
}
