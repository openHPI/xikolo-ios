//
//  ReachabilityHelper.swift
//  xikolo-ios
//
//  Created by Max Bothe on 12.12.17.
//  Copyright © 2017 HPI. All rights reserved.
//

import Foundation
import ReachabilitySwift

class ReachabilityHelper {

    static var reachability: Reachability = {
        return Reachability(hostname: Brand.host)!
    }()

    static var reachabilityStatus: Reachability.NetworkStatus {
        return self.reachability.currentReachabilityStatus
    }

    static func startObeserving() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(ReachabilityHelper.reachabilityChanged),
                                               name: ReachabilityChangedNotification,
                                               object: self.reachability)
        do {
            try self.reachability.startNotifier()
        } catch {
            print("Failed to start reachability notification")
        }
    }

    static func stopObeserving() {
        self.reachability.stopNotifier()
        NotificationCenter.default.removeObserver(self, name: ReachabilityChangedNotification, object: nil)
    }

    @objc class func reachabilityChanged() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: NotificationKeys.reachabilityChanged, object: nil)
        }
    }

}
