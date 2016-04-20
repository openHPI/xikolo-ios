//
//  Routes.swift
//  xikolo-ios
//
//  Created by Jonas Müller on 28.07.15.
//  Copyright © 2015 HPI. All rights reserved.
//

import Foundation

class Routes: NSObject {
    
    static let API_URL = "https://staging.openhpi.de/api/"
    static let BASE_URL = "https://staging.openhpi.de/"
    
    static let HEADER_USER_PLATFORM = "User-Platform"
    static let HEADER_USER_PLATFORM_VALUE = "iOS"
    
    static let COURSES = "courses/"
    static let AUTHENTICATE = "authenticate/"
    static let MY_PROFILE = "users/me"
    static let NEWS = "news"
    
    static let HTTP_ACCEPT_HEADER = "Accept"
    static let HTTP_ACCEPT_HEADER_VALUE = "application/vnd.xikolo.v1, application/json"
    static let HTTP_AUTH_HEADER = "Authorization"
    
    static let HTTP_PARAM_EMAIL = "email"
    static let HTTP_PARAM_PASSWORD = "password"
    
    static let REGISTER_URL = "https://open.hpi.de/account/new"

}

