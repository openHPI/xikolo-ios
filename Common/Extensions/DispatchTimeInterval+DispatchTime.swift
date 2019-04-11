//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation

public extension DispatchTimeInterval {

    var fromNow: DispatchTime {
        return DispatchTime.now() + self
    }

}
