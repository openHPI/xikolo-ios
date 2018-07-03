//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation
import Reachability

public class ReachabilityHelper {

    static var reachability: Reachability = {
        return Reachability(hostname: Brand.default.host)!
    }()

    public static var connection: Reachability.Connection {
        return self.reachability.connection
    }

    public static func startObserving() {
        do {
            try self.reachability.startNotifier()
        } catch {
            CrashlyticsHelper.shared.recordError(error)
            log.error("Failed to start reachability notification")
        }
    }

    public static func stopObserving() {
        self.reachability.stopNotifier()
    }

}
