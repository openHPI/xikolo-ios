//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation

public extension Int {

    public var seconds: DispatchTimeInterval {
        return DispatchTimeInterval.seconds(self)
    }

    public var second: DispatchTimeInterval {
        return seconds
    }

    public var milliseconds: DispatchTimeInterval {
        return DispatchTimeInterval.milliseconds(self)
    }

    public var millisecond: DispatchTimeInterval {
        return milliseconds
    }

}
