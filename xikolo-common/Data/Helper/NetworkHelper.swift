//
//  NetworkHelper.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 22.04.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import Foundation
import BrightFutures

class NetworkHelper {

    class func getRequestHeaders() -> [String: String] {
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

    class func resolvedRedirectURL(for url: URL) -> Future<URL, XikoloError> {
        let promise = Promise<URL, XikoloError>()

        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let redirectURL = response?.url {
                promise.success(redirectURL)
            } else if let error = error {
                promise.failure(XikoloError.network(error))
            } else {
                promise.failure(XikoloError.totallyUnknownError)
            }
        }

        task.resume()

        return promise.future
    }

}
