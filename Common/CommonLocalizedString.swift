//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation

// swiftlint:disable:next convenience_type
class CommonLocalizer {

    static func localizedString(_ key: String, comment: String) -> String {
        return NSLocalizedString(key, bundle: Bundle(for: CommonLocalizer.self), comment: comment)
    }

}

// swiftlint:disable:next identifier_name
func CommonLocalizedString(_ key: String, comment: String) -> String {
    return CommonLocalizer.localizedString(key, comment: comment)
}
