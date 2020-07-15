//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation

public enum LanguageLocalizer {

    public static func localizedDisplayName(for identifier: String) -> String? {
        let localeIdentifier = identifier == "cn" ? "zh" : identifier
        let locale = NSLocale(localeIdentifier: Locale.current.identifier)
        let displayName = locale.displayName(forKey: .languageCode, value: localeIdentifier)
        return displayName?.capitalized(with: Locale.current)
    }

    public static func nativeDisplayName(for identifier: String) -> String? {
        let localeIdentifier = identifier == "cn" ? "zh" : identifier
        let locale = NSLocale(localeIdentifier: localeIdentifier)
        let displayName = locale.displayName(forKey: .languageCode, value: localeIdentifier)
        return displayName?.capitalized(with: Locale(identifier: localeIdentifier))
    }

}
