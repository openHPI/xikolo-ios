//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import Foundation

public extension Bundle {

    var appGroupIdentifier: String? {
        return self.infoDictionary?["APP_GROUP_IDENTIFIER"] as? String
    }

    var urlScheme: String? {
        return self.infoDictionary?["URL_SCHEME"] as? String
    }

    var activityTypeOpenCourse: String? {
        return self.infoDictionary?["ACTIVITY_TYPE_OPEN_COURSE"] as? String
    }
}
