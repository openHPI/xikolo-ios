//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common

extension UserProfileHelper {

    public func logoutFromTestAccount() {
        #if DEBUG
            // Nothing to do here in DEBUG mode
        #else
            // Always logout test user
            if self.userId == Brand.default.testAccountUserId {
                self.logout()
            }
        #endif
    }

}
