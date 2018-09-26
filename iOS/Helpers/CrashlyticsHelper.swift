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

extension Crashlytics: ErrorReporter {

    public func report(_ error: Error) {
        self.recordError(error)
    }

}
