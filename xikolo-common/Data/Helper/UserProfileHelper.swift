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
import KeychainAccess

open class UserProfileHelper {

    static func login(_ email: String, password: String) -> Future<String, XikoloError> {
        let promise = Promise<String, XikoloError>()

        let url = Routes.AUTHENTICATE_API_URL
        Alamofire.request(url, method: .post, parameters:[
                Routes.HTTP_PARAM_EMAIL: email,
                Routes.HTTP_PARAM_PASSWORD: password,
        ], headers: [:]).responseJSON { response in
            // The API does not return valid JSON when returning a 401.
            // TODO: Remove once the API does that.
            if let response = response.response {
                if response.statusCode == 401 {
                    return promise.failure(XikoloError.authenticationError)
                }
            }

            if let json = response.result.value as? [String: Any] {
                if let token = json["token"] as? String, let id = json["user_id"] as? String {
                    UserProfileHelper.userToken = token
                    UserProfileHelper.userId = id
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
        UserProfileHelper.clearKeychain()
        CoreDataHelper.clearCoreDataStorage()
        self.postLoginStateChange()
    }

    static func isLoggedIn() -> Bool {
        return !self.userToken.isEmpty
    }

    static func postLoginStateChange() {
        SpineHelper.updateHttpHeaders()
        NotificationCenter.default.post(name: NotificationKeys.loginStateChangedKey, object: nil)
    }

}

extension UserProfileHelper {

    private static let keychain = Keychain(service: "de.xikolo.ios").accessibility(.afterFirstUnlock)
    private enum KeychainKey : String {
        case userId = "de.xikolo.ios.user-id"
        case userToken = "de.xikolo.ios.user-token"
    }

    static var userId: String? {
        get {
            return self.keychain[KeychainKey.userId.rawValue]
        }
        set {
            self.keychain[KeychainKey.userId.rawValue] = newValue
        }
    }

    static var userToken: String {
        get {
            return self.keychain[KeychainKey.userToken.rawValue] ?? ""
        }
        set {
            self.keychain[KeychainKey.userToken.rawValue] = newValue
        }
    }

    static func clearKeychain() {
        do {
            try self.keychain.removeAll()
        } catch {
            print("Failed to clear keychain - \(error)")
        }
    }

    static func migrateLegacyKeychain() {
        let defaults = UserDefaults.standard

        let legacyUserIdKey = "user"
        if let legacyUserId = defaults.string(forKey: legacyUserIdKey), !legacyUserId.isEmpty {
            self.userId = legacyUserId
            defaults.removeObject(forKey: legacyUserIdKey)
        }

        let legacyUserTokenKey = "user_token"
        if let legacyUserToken = defaults.string(forKey: legacyUserTokenKey), !legacyUserToken.isEmpty {
            self.userToken = legacyUserToken
            defaults.removeObject(forKey: legacyUserTokenKey)
        }

        defaults.synchronize()
    }
}
