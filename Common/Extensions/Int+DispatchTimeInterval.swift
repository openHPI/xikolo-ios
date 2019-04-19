//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

public extension Int {

    var seconds: DispatchTimeInterval {
        return DispatchTimeInterval.seconds(self)
    }

    var second: DispatchTimeInterval {
        return self.seconds
    }

    var milliseconds: DispatchTimeInterval {
        return DispatchTimeInterval.milliseconds(self)
    }

    var millisecond: DispatchTimeInterval {
        return self.milliseconds
    }

}
