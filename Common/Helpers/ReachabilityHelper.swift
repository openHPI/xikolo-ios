//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation
import Reachability

public enum ReachabilityHelper {

    static var reachability: Reachability = {
        return try! Reachability(hostname: Brand.default.host)
    }()

    public static var connection: Reachability.Connection {
        return self.reachability.connection
    }

    public static var hasConnection: Bool {
        return self.connection != .unavailable
    }

    public static func startObserving() throws {
        try self.reachability.startNotifier()
    }

    public static func stopObserving() {
        self.reachability.stopNotifier()
    }

}
