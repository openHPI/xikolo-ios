//
//  Reachability.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 16.08.17.
//  Copyright © 2017 HPI. All rights reserved.
//

import Foundation
import ReachabilitySwift

class ReachabilityHelper {

    static var reachability: Reachability = {
        return Reachability(hostname: Brand.Host)!
    }()

    static var isOffline = false

    class func setupReachability(_ host: String? = Brand.Host) {
        NotificationCenter.default.addObserver(self, selector: #selector(ReachabilityHelper.reachabilityChanged), name: ReachabilityChangedNotification, object: self.reachability)
        do {
            try self.reachability.startNotifier()
        } catch {
            print("Failed to start reachability notification")
        }
    }

    @objc class func reachabilityChanged() {
        self.isOffline = !reachability.isReachable
        NotificationCenter.default.post(name: NotificationKeys.reachabilityChanged, object: reachability)
    }

}
