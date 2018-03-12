//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation

extension Int {

    var seconds: DispatchTimeInterval {
        return DispatchTimeInterval.seconds(self)
    }

    var second: DispatchTimeInterval {
        return seconds
    }

    var milliseconds: DispatchTimeInterval {
        return DispatchTimeInterval.milliseconds(self)
    }

    var millisecond: DispatchTimeInterval {
        return milliseconds
    }

}
