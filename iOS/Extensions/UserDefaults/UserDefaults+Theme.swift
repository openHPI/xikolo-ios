//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import Foundation

enum Theme: Int, CaseIterable {
    case device 
    case light
    case dark

    static var orderedValues: [Theme] {
        return [.device, .light, .dark]
    }

    var title: String? {
        switch self {
        case .device:
            return NSLocalizedString("settings.appearance.device", comment: "Title for selecting device apperance option")
        case .light:
            return NSLocalizedString("settings.appearance.light", comment: "Title for selecting light apperance option")
        case .dark:
            return NSLocalizedString("settings.appearance.dark", comment: "Title for selecting dark apperance option")
        default:
            return nil
        }
    }
}

@available(iOS 12.0, *)
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

extension UserDefaults {
//    var theme: Theme {
//        get {
//            register(defaults: [#function: Theme.device.rawValue])
//            return Theme(rawValue: integer(forKey: #function)) ?? .device
//        }
//        set {
//            set(newValue.rawValue, forKey: #function)
//        }
//    }

    private static let appearanceKey = "de.xikolo.ios.appearance"

    var theme: Theme {
        get {
            let rawValue = self.integer(forKey: Self.appearanceKey)
            guard let value = Theme(rawValue: rawValue) else { return .device }
            return value
        }
        set {
            self.set(newValue.rawValue, forKey: Self.appearanceKey)
        }
    }
}
