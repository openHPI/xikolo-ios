//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures
import Foundation

public struct NetworkHelper {

    public static func requestHeaders(for url: URL) -> [String: String] {
        var headers = [
            Routes.Header.acceptKey: Routes.Header.acceptValue,
        ]

        if UserProfileHelper.shared.isLoggedIn, url.host == Routes.base.host {
            headers[Routes.Header.authKey] = Routes.Header.authValuePrefix + UserProfileHelper.shared.userToken
        }

        headers[Routes.Header.userPlatformKey] = Routes.Header.userPlatformValue
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
