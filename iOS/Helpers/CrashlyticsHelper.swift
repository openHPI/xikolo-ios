//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import Crashlytics

struct CrashlyticsHelper {

    static var shared: Crashlytics {
        return Crashlytics.sharedInstance()
    }

}

extension Crashlytics {

    func recordAPIError(_ error: XikoloError) {
        guard case .api(_) = error else { return }
        if case let .api(.responseError(statusCode: statusCode, headers: _)) = error,
            !(200 ... 299 ~= statusCode || statusCode == 406 || statusCode == 503) { return }
        CrashlyticsHelper.shared.recordError(error)
    }

}

extension Crashlytics: SyncPushEngineDelegate {

    public func didFailToPushResourceModification(withError error: XikoloError) {
        self.recordError(error)
    }

}
