//
//  NetworkIndicator.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 12.07.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import UIKit

class NetworkIndicator {

    private static let queue = DispatchQueue(label: "de.xikolo.queue.network-indicator")
    private (set) static var counter = 0

    class func start() {
        self.queue.sync {
            self.counter += 1
            self.update()
        }
    }

    class func end() {
        self.queue.sync {
            self.counter = max(self.counter - 1, 0)
            self.update()
        }
    }

    private class func update() {
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = counter > 0
        }
    }

}
