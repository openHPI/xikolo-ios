//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common

extension UserProfileHelper {

    public func logoutFromTestAccount() {
        guard !UserDefaults.standard.didLogoutTestAccount else { return }

        if self.userId == Brand.default.testAccountUserId {
            self.logout(runPostActions: false)
        }

        UserDefaults.standard.didLogoutTestAccount = true
    }

}
