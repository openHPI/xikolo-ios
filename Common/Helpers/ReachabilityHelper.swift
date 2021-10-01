//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import Foundation
import Reachability

public enum ReachabilityHelper {

    public enum Connection {
        case wifi
        case cellular
        case offline
    }

    private static var reachability: Reachability = {
        return try! Reachability(hostname: Brand.default.host) // swiftlint:disable:this force_try
    }()

    public static var connection: Connection {
        switch self.reachability.connection {
        case .wifi:
            return .wifi
        case .cellular:
            return .cellular
        case .none, .unavailable:
            return .offline
        }
    }

    public static var hasConnection: Bool {
        return self.connection != .offline
    }

    public static func startObserving() throws {
        try self.reachability.startNotifier()
    }

    public static func stopObserving() {
        self.reachability.stopNotifier()
    }

}
