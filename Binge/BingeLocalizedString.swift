//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation

// swiftlint:disable:next convenience_type
class BingeLocalizer {

    static func localizedString(_ key: String, comment: String) -> String {
        // swiftlint:disable:next nslocalizedstring_key
        return NSLocalizedString(key, bundle: Bundle(for: BingeLocalizer.self), comment: comment)
    }

}

// swiftlint:disable:next identifier_name
func BingeLocalizedString(_ key: String, comment: String) -> String {
    return BingeLocalizer.localizedString(key, comment: comment)
}
