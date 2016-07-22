//
//  User.swift
//  xikolo-ios
//
//  Created by Jonas Müller on 08.07.15.
//  Copyright © 2015 HPI. All rights reserved.
//

import Alamofire
import BrightFutures
import Foundation

public class UserProfileHelper {

    static let preferenceUser = "user"
    static let preferenceToken = "user_token"

    static private let prefs = NSUserDefaults.standardUserDefaults()

    static func login(email: String, password: String, completionHandler: (token: String?, error: NSError?) -> ()) {
        let url = Routes.AUTHENTICATE_API_URL

        Alamofire.request(.POST, url, headers: NetworkHelper.getRequestHeaders(), parameters:[
                Routes.HTTP_PARAM_EMAIL: email,
                Routes.HTTP_PARAM_PASSWORD: password,
            ]).responseJSON { response in
                if let json = response.result.value {
                    if let token = json["token"] as? String {
                        UserProfileHelper.saveToken(token)
                        NSNotificationCenter.defaultCenter().postNotificationName(NotificationKeys.loginSuccessfulKey, object: nil)
                        completionHandler(token: token, error: nil)
                        return
                    }
                }
                completionHandler(token: nil, error: response.result.error)
        }
    }

    static func createEnrollement(courseId: String, completionHandler: (success: Bool, error: NSError?) -> ()) {
        let url = Routes.ENROLLMENTS_API_URL

        Alamofire.request(.POST, url, headers: NetworkHelper.getRequestHeaders(), parameters:[
                Routes.HTTP_PARAM_COURSE_ID: courseId,
            ]).responseJSON { response in
                if let json = response.result.value {
                    if (json["id"] as? String) != nil {
                        completionHandler(success: true, error: nil)
                        return
                    }
                }
                completionHandler(success: false, error: response.result.error)
        }
    }

    static func deleteEnrollement(courseId: String, completionHandler: (success: Bool, error: NSError?) -> ()) {
        let url = Routes.ENROLLMENTS_API_URL + courseId

        Alamofire.request(.DELETE, url, headers: NetworkHelper.getRequestHeaders()).response { (request, response, data, error) in
            completionHandler(success: error == nil, error: error)
        }
    }

    static func logout() {
        prefs.removePersistentDomainForName(NSBundle.mainBundle().bundleIdentifier!)
        NSNotificationCenter.defaultCenter().postNotificationName(NotificationKeys.logoutSuccessfulKey, object: nil)
        prefs.synchronize()
    }

    static func getUser() -> Future<UserProfile, XikoloError> {
        if let user = loadUser() {
            return Future.init(value: user)
        } else {
            return UserProfileProvider.getMyProfile().onSuccess { user in
                UserProfileHelper.saveUser(user)
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
