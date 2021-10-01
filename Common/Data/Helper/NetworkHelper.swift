//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures
import Foundation

public enum NetworkHelper {

    public static func requestHeaders(for url: URL, additionalHeaders: [String: String] = [:]) -> [String: String] {
        var headers = [
            Routes.Header.acceptKey: Routes.Header.acceptValue,
            Routes.Header.userPlatformKey: Routes.Header.userPlatformValue,
            Routes.Header.userAgentKey: Routes.Header.userAgentValue,
            Routes.Header.acceptLanguageKey: Locale.supportedCurrent.identifier,
        ]

        for (key, value) in additionalHeaders {
            headers[key] = value
        }

        if UserProfileHelper.shared.isLoggedIn, url.host == Routes.base.host {
            headers[Routes.Header.authKey] = Routes.Header.authValuePrefix + UserProfileHelper.shared.userToken
        }

        return headers
    }

    public static func request(for url: URL) -> NSMutableURLRequest {
        let request = NSMutableURLRequest(url: url)
        request.allHTTPHeaderFields = self.requestHeaders(for: url)
        return request
    }

    public static func escape(_ string: String ) -> String {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,:="

        var allowedCharacterSet = CharacterSet.urlQueryAllowed
        allowedCharacterSet.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        return string.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? string
    }

}
