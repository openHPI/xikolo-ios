//
//  Created for xikolo-ios under MIT license.
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
