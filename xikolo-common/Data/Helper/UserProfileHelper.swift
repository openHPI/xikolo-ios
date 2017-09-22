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
import CoreData

open class UserProfileHelper {

    static fileprivate let prefs = UserDefaults.standard

    static func login(_ email: String, password: String) -> Future<String, XikoloError> {
        let promise = Promise<String, XikoloError>()

        let url = Routes.AUTHENTICATE_API_URL
        Alamofire.request(url, method: .post, parameters:[
                Routes.HTTP_PARAM_EMAIL: email,
                Routes.HTTP_PARAM_PASSWORD: password,
        ], headers: NetworkHelper.getRequestHeaders()).responseJSON { response in
            // The API does not return valid JSON when returning a 401.
            // TODO: Remove once the API does that.
            if let response = response.response {
                if response.statusCode == 401 {
                    return promise.failure(XikoloError.authenticationError)
                }
            }

            if let json = response.result.value as? [String: Any] {
                if let token = json["token"] as? String, let id = json["user_id"] as? String {
                    UserProfileHelper.saveToken(token)
                    UserProfileHelper.saveId(id)
                    self.postLoginStateChange()
                    return promise.success(token)
                }
                return promise.failure(XikoloError.authenticationError)
            }
            if let error = response.result.error {
                return promise.failure(XikoloError.network(error))
            }
            return promise.failure(XikoloError.totallyUnknownError)
        }
        return promise.future
    }

    static func logout() {
        prefs.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        prefs.synchronize()
        CoreDataHelper.clearCoreDataStorage()
        self.postLoginStateChange()
    }

    static func isLoggedIn() -> Bool {
        return !getToken().isEmpty
    }

    static func getToken() -> String {
        return get(.token) ?? ""
    }

    static func save(_ key: UserDefaultsKeys.UserProfileKey, withValue value: String) {
        prefs.set(value, forKey: key.rawValue)
        prefs.synchronize()
    }

    static func get(_ key: UserDefaultsKeys.UserProfileKey) -> String? {
        return prefs.string(forKey: key.rawValue)
    }

    static func getUserId() -> String? {
        return self.get(.user)
    }

    static func saveToken(_ token: String) {
        save(.token, withValue: token)
    }

    static func saveId(_ id: String) {
        save(.user, withValue: id)
    }

    static func postLoginStateChange() {
        SpineHelper.updateHttpHeaders()
        NotificationCenter.default.post(name: NotificationKeys.loginStateChangedKey, object: nil)
    }

}
