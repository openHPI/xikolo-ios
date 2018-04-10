//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation
import UIKit

struct Brand: XikoloBrand {

    struct Color: XikoloBrandColor {
        static let primary = UIColor(red: 11 / 255, green: 114 / 255, blue: 181 / 255, alpha: 1.0)
        static let secondary = UIColor(red: 145 / 255, green: 100 / 255, blue: 167 / 255, alpha: 1.0)
        static let tertiary = UIColor(red: 167 / 255, green: 202 / 255, blue: 108 / 255, alpha: 1.0)
    }

    static let host = "openwho.org"
    static let imprintURL = Routes.base.appendingPathComponents(["pages", "about"])
    static let privacyURL = Routes.base.appendingPathComponents(["pages", "terms_of_use"])

    static let platformTitle = "who"

    static var singleSignOnButtonTitle: String? {
        return "WHO Identity (WIMS)"
    }

    static let copyrightName = "WHO"
    static var poweredByText: String {
        return "Powered by HPI / openHPI"
    }

}
