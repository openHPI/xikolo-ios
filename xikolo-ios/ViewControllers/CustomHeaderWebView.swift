//
//  CustomHeaderWebView.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 29.03.17.
//  Copyright © 2017 HPI. All rights reserved.
//

import WebKit

class CustomHeaderWebView: WKWebView {

    var header: [String : String]?

    override func load(_ request: URLRequest) -> WKNavigation? {
        var mutableRequest = request
        guard let headerDict = header else { return super.load(request) }
        for entry in headerDict {
            mutableRequest.setValue(entry.value, forHTTPHeaderField: entry.key)
        }
        return super.load(mutableRequest)
    }
}
