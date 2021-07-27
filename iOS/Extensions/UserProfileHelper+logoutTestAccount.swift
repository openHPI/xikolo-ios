//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common

extension UserProfileHelper {

    public func logoutFromTestAccount() {
        // Always logout test user
        // guard !UserDefaults.standard.didLogoutTestAccount else { return }

        if self.userId == Brand.default.testAccountUserId {
            self.logout()
        }

        UserDefaults.standard.didLogoutTestAccount = true
    }

}
