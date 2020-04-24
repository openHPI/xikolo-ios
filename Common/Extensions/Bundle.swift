//
//  Created for xikolo-ios under MIT license.
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

    var courseOpen: String? {
        return self.infoDictionary?["COURSE_OPEN"] as? String
    }
}
