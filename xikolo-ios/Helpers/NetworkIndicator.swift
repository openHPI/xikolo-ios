//
//  NetworkIndicator.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 12.07.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import UIKit
import Spine

class NetworkIndicator {

    static var counter = 0

    class func start() {
        counter += 1
        update()
    }

    class func end() {
        counter -= 1
        update()
    }

    fileprivate class func update() {
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = counter > 0
        }
    }

}

struct XikoloClientDelegate: HTTPClientDelegate {

    func httpClient(_ client: HTTPClient, willPerformRequestWithMethod method: String, url URL: Foundation.URL, payload: Data?) {
        NetworkIndicator.start()
    }

    func httpClient(_ client: HTTPClient, didPerformRequestWithMethod method: String, url URL: Foundation.URL, success: Bool) {
        NetworkIndicator.end()
    }
    
}
