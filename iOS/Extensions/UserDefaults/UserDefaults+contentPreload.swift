//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation

enum CourseItemContentPreloadSetting: Int, CustomStringConvertible {
    case wifiOnly = 0  // default value must be zero
    case never
    case always

    static var orderedValues: [CourseItemContentPreloadSetting] {
        return [.never, .wifiOnly, .always]
    }

    var description: String {
        switch self {
        case .never:
            return NSLocalizedString("settings.course-item-content-preload.never", comment: "course content preload setting: never")
        case .wifiOnly:
            return NSLocalizedString("settings.course-item-content-preload.wifi-only", comment: "course content preload setting: wifi only")
        case .always:
            return NSLocalizedString("settings.course-item-content-preload.always", comment: "course content preload setting: always")
        }
    }

}

extension UserDefaults {

    private static let contentPreloadSettingKey = "de.xikolo.ios.course-item.content.preload"

    var contentPreloadSetting: CourseItemContentPreloadSetting {
        get {
            let rawValue = self.integer(forKey: UserDefaults.contentPreloadSettingKey)
            guard let value = CourseItemContentPreloadSetting(rawValue: rawValue) else { return .wifiOnly }
            return value
        }
        set {
            self.set(newValue.rawValue, forKey: UserDefaults.contentPreloadSettingKey)
        }
    }

}
