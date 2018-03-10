//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation

extension Date {

    func subtractingTimeInterval(_ timeInterval: TimeInterval) -> Date {
        return self.addingTimeInterval(-1*timeInterval)
    }

    var inPast: Bool {
        return !self.inFuture
    }

    var inFuture: Bool {
        return self.timeIntervalSinceNow > 0
    }

}
