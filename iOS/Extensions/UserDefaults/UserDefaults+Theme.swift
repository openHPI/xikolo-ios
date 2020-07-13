//
//  Created for xikolo-ios under MIT license.
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
            register(defaults: [#function: Theme.device.rawValue])
            return Theme(rawValue: integer(forKey: #function)) ?? .device
        }
        set {
            set(newValue.rawValue, forKey: #function)
        }
    }
}
