//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation

class BingeLocalizer { // swiftlint:disable:this convenience_type

    static func localizedString(_ key: String, comment: String) -> String {
        let bundle = Bundle(for: BingeLocalizer.self)
        return NSLocalizedString(key, bundle: bundle, comment: comment)
    }

}

func BingeLocalizedString(_ key: String, comment: String) -> String {
    return BingeLocalizer.localizedString(key, comment: comment)
}
