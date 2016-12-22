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

    private class func update() {
        dispatch_async(dispatch_get_main_queue()) {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = counter > 0
        }
    }

}

struct XikoloClientDelegate: HTTPClientDelegate {

    func httpClient(client: HTTPClient, willPerformRequestWithMethod method: String, URL: NSURL, payload: NSData?) {
        NetworkIndicator.start()
    }

    func httpClient(client: HTTPClient, didPerformRequestWithMethod method: String, URL: NSURL, success: Bool) {
        NetworkIndicator.end()
    }
    
}
