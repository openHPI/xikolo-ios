//
//  User.swift
//  xikolo-ios
//
//  Created by Jonas Müller on 08.07.15.
//  Copyright © 2015 HPI. All rights reserved.
//

import Alamofire
import Foundation

public class UserProfileHelper {

    static let preferenceUser = "user"
    static let preferenceToken = "user_token"

    static private let prefs = NSUserDefaults.standardUserDefaults()

    static func login(email: String, password: String, completionHandler: (token: String?, error: NSError?) -> ()) {
        let url = Routes.API_URL + Routes.AUTHENTICATE

        Alamofire.request(.POST, url, headers: NetworkHelper.getRequestHeaders(), parameters:[
                Routes.HTTP_PARAM_EMAIL: email,
                Routes.HTTP_PARAM_PASSWORD: password,
            ]).responseJSON { response in
                if let json = response.result.value {
                    if let token = json["token"] as? String {
                        UserProfileHelper.saveToken(token)
                        completionHandler(token: token, error: nil)
                        return
                    }
                }
                completionHandler(token: nil, error: response.result.error)
        }
    }

    static func logout() {
        prefs.removePersistentDomainForName(NSBundle.mainBundle().bundleIdentifier!)
        prefs.synchronize()
    }

    static func getUser(completionHandler: (UserProfile?, NSError?) -> ()) {
        if let user = loadUser() {
            completionHandler(user, nil)
        } else {
            UserProfileProvider.getMyProfile() { (user: UserProfile?, error: NSError?) -> () in
                if user != nil {
                    UserProfileHelper.saveUser(user!)
                }
                completionHandler(user, error)
            }
        }
    }

    static private func loadUser() -> UserProfile? {
        if let data = prefs.objectForKey(preferenceUser) as? NSData {
            return NSKeyedUnarchiver.unarchiveObjectWithData(data) as? UserProfile
        }
        return nil
    }

    static func saveUser(user: UserProfile) {
        prefs.setObject(NSKeyedArchiver.archivedDataWithRootObject(user), forKey: preferenceUser)
        prefs.synchronize()
    }

    static func isLoggedIn() -> Bool {
        return !getToken().isEmpty
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
