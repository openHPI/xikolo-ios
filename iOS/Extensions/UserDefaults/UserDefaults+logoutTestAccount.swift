//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation

extension UserDefaults {

    private static let logoutTestAccount = "de.xikolo.ios.account.logout-test-account-2019-12"

    var didLogoutTestAccount: Bool {
        get {
            return self.bool(forKey: Self.logoutTestAccount)
        }
        set {
            self.set(newValue, forKey: Self.logoutTestAccount)
        }
    }

}
