//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import Foundation

@objc enum Theme: Int {
  case device
  case light
  case dark
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
