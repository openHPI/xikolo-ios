//
//  ReachabilityHelper.swift
//  xikolo-ios
//
//  Created by Max Bothe on 12.12.17.
//  Copyright © 2017 HPI. All rights reserved.
//

import Foundation
import Reachability

class ReachabilityHelper {

    static var reachability: Reachability = {
        return Reachability(hostname: Brand.host)!
    }()

    static var connection: Reachability.Connection {
        return self.reachability.connection
    }

    static func startObserving() {
        do {
            try self.reachability.startNotifier()
        } catch {
            log.error("Failed to start reachability notification")
        }
    }

    static func stopObserving() {
        self.reachability.stopNotifier()
    }

}
