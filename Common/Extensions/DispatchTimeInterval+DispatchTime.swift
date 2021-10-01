//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import Foundation

public extension DispatchTimeInterval {

    var fromNow: DispatchTime {
        return DispatchTime.now() + self
    }

}
