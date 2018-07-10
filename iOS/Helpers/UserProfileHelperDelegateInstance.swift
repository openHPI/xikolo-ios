//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import Foundation

class UserProfileHelperDelegateInstance: UserProfileHelperDelegate {

    func networkActivityStarted() {
        NetworkIndicator.start()
    }

    func networkActivityEnded() {
        NetworkIndicator.end()
    }

    public func didFailToClearKeychain(withError error: Error) {
        CrashlyticsHelper.shared.recordError(error)
    }

    public func didFailToClearCoreDataEnitity(withError error: XikoloError) {
        CrashlyticsHelper.shared.recordError(error)
    }

}
