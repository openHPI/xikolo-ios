//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation
import BrightFutures

class NetworkHelper {

    class func getRequestHeaders() -> [String: String] {
        var headers = [
            Routes.HTTP_ACCEPT_HEADER: Routes.HTTP_ACCEPT_HEADER_VALUE,
        ]
        if UserProfileHelper.isLoggedIn() {
            headers[Routes.HTTP_AUTH_HEADER] = Routes.HTTP_AUTH_HEADER_VALUE_PREFIX + UserProfileHelper.userToken
        }
        headers[Routes.HEADER_USER_PLATFORM] = Routes.HEADER_USER_PLATFORM_VALUE
        return headers
    }

    class func getRequestForURL(_ url: String) -> NSMutableURLRequest {
        // TODO: test whether url is a valid url
        let url = URL(string: url).require(hint: "Can't build URLRequest from invalid URL")
        let request = NSMutableURLRequest(url: url)
        request.allHTTPHeaderFields = getRequestHeaders()
        return request
    }

    static func escape(_ string: String ) -> String {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,:="

        var allowedCharacterSet = CharacterSet.urlQueryAllowed
        allowedCharacterSet.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        return string.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? string
    }

}
