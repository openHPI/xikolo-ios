//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation
import UIKit

struct Brand: XikoloBrand {

    struct Color: XikoloBrandColor {
        static let primary = UIColor(red: 171 / 255, green: 179 / 255, blue: 36 / 255, alpha: 1.0)
        static let secondary = UIColor(red: 171 / 255, green: 179 / 255, blue: 36 / 255, alpha: 1.0)
        static let tertiary = UIColor(red: 171 / 255, green: 179 / 255, blue: 36 / 255, alpha: 1.0)
    }

    static let host = "mooc.house"
    static let imprintURL = Routes.base.appendingPathComponents(["pages", "imprint"])
    static let privacyURL = Routes.base.appendingPathComponents(["pages", "privacy"])

    static let platformTitle = "moochouse"

    static let copyrightName = "HPI"

}
