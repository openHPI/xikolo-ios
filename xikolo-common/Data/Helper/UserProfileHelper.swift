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

    enum Keys : String {
        case user = "user"
        case token = "user_token"
        case welcome = "show_welcome_screen"
    }

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
                    NotificationCenter.default.post(name: NotificationKeys.loginSuccessfulKey, object: nil)
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
        NotificationCenter.default.post(name: NotificationKeys.logoutSuccessfulKey, object: nil)
        prefs.synchronize()
        CoreDataHelper.clearCoreDataStorage()
    }

    static func isLoggedIn() -> Bool {
        return !getToken().isEmpty
    }

    static func getToken() -> String {
        return get(.token) ?? ""
    }

    static func save(_ key: Keys, withValue value: String) {
        prefs.set(value, forKey: key.rawValue)
        prefs.synchronize()
    }

    static func get(_ key: Keys) -> String? {
        return prefs.string(forKey: key.rawValue)
    }

    static func getUserId() -> String? {
        if let id = get(.user) {
            return id
        } else {
            return nil
        }
    }

    static func saveToken(_ token: String) {
        save(.token, withValue: token)
        NotificationCenter.default.post(name: NotificationKeys.loginSuccessfulKey, object: nil)
        prefs.synchronize()
        refreshUserDependentData()
    }

    static func refreshUserDependentData() {
        UserHelper.syncMe()
        CourseHelper.refreshCourses()
        CourseDateHelper.syncCourseDates()
        NewsArticleHelper.syncNewsArticles()
    }

    static func saveId(_ id: String) {
        save(.user, withValue: id)
    }

}
