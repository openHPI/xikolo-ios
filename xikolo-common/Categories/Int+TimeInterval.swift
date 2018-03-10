//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation

public extension Int {

    public var days: TimeInterval {
        return TimeInterval(self * 24 * 60 * 60)
    }

    public var day: TimeInterval {
        return self.days
    }

}
