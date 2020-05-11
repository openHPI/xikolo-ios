//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import FirebaseCrashlytics

extension Crashlytics: ErrorReporter {

    public func report(_ error: Error) {
        self.record(error: error)
    }

    public func remember(_ value: Any, forKey key: String) {
        self.setCustomValue(value, forKey: key)
    }

}
