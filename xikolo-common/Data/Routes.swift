//
//  Routes.swift
//  xikolo-ios
//
//  Created by Jonas Müller on 28.07.15.
//  Copyright © 2015 HPI. All rights reserved.
//

import Foundation

// TODO: all urls should be of type URL to avoid checks when using these urls
struct Routes {

    static let API_V2_URL = Brand.BaseURL + "/api/v2/"

    static let AUTHENTICATE_URL = API_V2_URL + "authenticate/"

    static let COURSES_URL = Brand.BaseURL + "/courses/"
    static let DASHBOARD_URL = Brand.BaseURL + "/dashboard"
    static let PROFILE_URL = DASHBOARD_URL + "/profile"
    static let NEWS_URL = Brand.BaseURL + "/news"
    static let REGISTER_URL = Brand.BaseURL + "/account/new?in_app=true"
    static let SSO_URL = Brand.BaseURL + "?in_app=true&redirect_to=/auth/" + Brand.PlatformTitle

    static let HEADER_USER_PLATFORM = "User-Platform"
    static let HEADER_USER_PLATFORM_VALUE = "iOS"

    static let HTTP_ACCEPT_HEADER = "Accept"
    static let HTTP_ACCEPT_HEADER_VALUE = "application/vnd.api+json; xikolo-version=2"
    static let HTTP_AUTH_HEADER = "Authorization"
    static let HTTP_AUTH_HEADER_VALUE_PREFIX = "Token token="
    static let HTTP_API_Version_Expiration_Date_Header = "X-Api-Version-Expiration-Date"

    static let HTTP_PARAM_EMAIL = "email"
    static let HTTP_PARAM_PASSWORD = "password"

    static var localizedForgotPasswordURL: URL {
        var urlComponents = URLComponents(string: Brand.BaseURL + "/account/reset/new")
        var queryItems = [URLQueryItem(name: "in_app", value: "true")]
        if let locale = NSLocale.preferredLanguages.first {
            queryItems.append(URLQueryItem(name: "locale", value: locale))
        }
        urlComponents?.queryItems = queryItems

        guard let url = urlComponents?.url else {
            fatalError("Failed to create url for password reset")
        }

        return url
    }

}
