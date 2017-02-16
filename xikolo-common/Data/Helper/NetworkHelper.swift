//
//  NetworkHelper.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 22.04.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import Foundation

class NetworkHelper {

    class func getRequestHeaders() -> [String: String]{
        var headers = [
            Routes.HTTP_ACCEPT_HEADER: Routes.HTTP_ACCEPT_HEADER_VALUE,
        ]
        if UserProfileHelper.isLoggedIn() {
            headers[Routes.HTTP_AUTH_HEADER] = Routes.HTTP_AUTH_HEADER_VALUE_PREFIX + UserProfileHelper.getToken()
        }
        headers[Routes.HEADER_USER_PLATFORM] = Routes.HEADER_USER_PLATFORM_VALUE
        return headers
    }
    
    class func getRequestForURL(_ url: String) -> NSMutableURLRequest {
        //TODO: test whether url is a valid url
        let url = URL(string: url)
        let request = NSMutableURLRequest(url: url!)
        request.allHTTPHeaderFields = getRequestHeaders()
        return request
    }
}
