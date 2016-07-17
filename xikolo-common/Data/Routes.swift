//
//  Routes.swift
//  xikolo-ios
//
//  Created by Jonas Müller on 28.07.15.
//  Copyright © 2015 HPI. All rights reserved.
//

import Foundation

struct Routes {

    static let API_URL = Brand.BASE_URL + "/api"
    static let API_V2_URL = Brand.BASE_URL + "/api/v2/"

    static let COURSES_API_URL = API_URL + "/courses/"
    static let AUTHENTICATE_API_URL = API_URL + "/authenticate/"
    static let MY_PROFILE_API_URL = API_URL + "/users/me"
    static let ENROLLMENTS_API_URL = API_URL + "/users/me/enrollments/"

    static let COURSES_URL = Brand.BASE_URL + "/courses/"
    static let NEWS_URL = Brand.BASE_URL + "/news"
    static let REGISTER_URL = Brand.BASE_URL + "/account/new"

    static let HEADER_USER_PLATFORM = "User-Platform"
    static let HEADER_USER_PLATFORM_VALUE = "iOS"

    static let HTTP_ACCEPT_HEADER = "Accept"
    static let HTTP_ACCEPT_HEADER_VALUE = "application/vnd.xikolo.v1, application/json"
    static let HTTP_AUTH_HEADER = "Authorization"
    static let HTTP_AUTH_HEADER_VALUE_PREFIX = "Token token="

    static let HTTP_PARAM_EMAIL = "email"
    static let HTTP_PARAM_PASSWORD = "password"
    static let HTTP_PARAM_COURSE_ID = "course_id"

}
