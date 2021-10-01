//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import Foundation

extension Date {

    public var inPast: Bool {
        return !self.inFuture
    }

    public var inFuture: Bool {
        return self.timeIntervalSinceNow > 0
    }

}
