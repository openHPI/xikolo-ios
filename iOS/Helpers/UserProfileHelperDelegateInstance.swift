//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import Common

class UserProfileHelperDelegateInstance: UserProfileHelperDelegate {

    func networkActivityStarted() {
        NetworkIndicator.start()
    }

    func networkActivityEnded() {
        NetworkIndicator.end()
    }

}
