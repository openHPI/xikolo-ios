//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import Common
import Foundation

@available(iOS 13.0, *)
@objc enum Theme: Int, CaseIterable {
    case device
    case light
    case dark

    var title: String? {
        switch self {
        case .device:
            return NSLocalizedString("settings.appearance.device", comment: "Title for selecting device apperance option")
        case .light:
            return NSLocalizedString("settings.appearance.light", comment: "Title for selecting light apperance option")
        case .dark:
            return NSLocalizedString("settings.appearance.dark", comment: "Title for selecting dark apperance option")
        }
    }
}

@available(iOS 13.0, *)
extension Theme {
    var userInterfaceStyle: UIUserInterfaceStyle {
        switch self {
        case .device:
            return .unspecified
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
}

@available(iOS 13.0, *)
extension UserDefaults {

    private static let appearanceKey = "de.xikolo.ios.appearance"

    @objc dynamic var theme: Theme {
        get {
            self.register(defaults: [Self.appearanceKey: Theme.device.rawValue])
            return Theme(rawValue: self.integer(forKey: Self.appearanceKey)) ?? .device
        }
        set {
            self.set(newValue.rawValue, forKey: Self.appearanceKey)
        }
    }
}
