//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation

extension Date {

    public func subtractingTimeInterval(_ timeInterval: TimeInterval) -> Date {
        return self.addingTimeInterval(-1 * timeInterval)
    }

    public var inPast: Bool {
        return !self.inFuture
    }

    public var inFuture: Bool {
        return self.timeIntervalSinceNow > 0
    }

}
