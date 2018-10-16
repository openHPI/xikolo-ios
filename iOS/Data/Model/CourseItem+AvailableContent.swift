//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common

extension CourseItem {

    var hasAvailableContent: Bool {
        let itemContentIsAvailableOffline = self.content?.isAvailableOffline ?? false
        return ReachabilityHelper.hasConnection || itemContentIsAvailableOffline
    }

}
