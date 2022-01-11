//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import WebKit

class CustomHeaderWebView: WKWebView {

    var header: [String: String]?

    override func load(_ request: URLRequest) -> WKNavigation? {
        var mutableRequest = request
        guard let headerDict = header else { return super.load(request) }
        for entry in headerDict {
            mutableRequest.setValue(entry.value, forHTTPHeaderField: entry.key)
        }

        return super.load(mutableRequest)
    }
}
