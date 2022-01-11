//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import Foundation

extension Locale {

    public static var supportedCurrent: Locale {
        if Bundle.main.localizations.contains(Locale.current.languageCode ?? Locale.current.identifier) {
            return Locale.current
        } else {
            return Locale(identifier: "en")
        }
    }

}
