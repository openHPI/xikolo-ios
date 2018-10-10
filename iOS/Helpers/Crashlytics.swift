//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import Crashlytics

extension Crashlytics: ErrorReporter {

    public func report(_ error: Error) {
        self.recordError(error)
    }

    public func reportStoryboardError(reason: String) {
        self.recordCustomExceptionName("Storyboard Error", reason: reason, frameArray: [])
    }

    public func remember(_ value: Any?, forKey key: String) {
        self.setObjectValue(value, forKey: key)
    }

}
