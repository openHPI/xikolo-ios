//
//  Created for xikolo-ios under MIT license.
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
