//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation
import UIKit

struct Brand: XikoloBrand {

    struct Color: XikoloBrandColor {
        static let primary = UIColor(red: 240 / 255, green: 171 / 255, blue: 0 / 255, alpha: 1.0)
        static let secondary = UIColor(red: 34 / 255, green: 108 / 255, blue: 169 / 255, alpha: 1.0)
        static let tertiary = UIColor(red: 138 / 255, green: 181 / 255, blue: 78 / 255, alpha: 1.0)

        static var window: UIColor {
            return self.secondary
        }
    }

    static let host = "open.sap.com"
    static let imprintURL = URL(string: "http://www.sap.com/corporate/en/legal/impressum.html").require(hint: "Invalid imprint URL")
    static let privacyURL = URL(string: "http://www.sap.com/corporate/en/legal/privacy.html").require(hint: "Invalid privacy URL")

    static let platformTitle = "sap"

    static var singleSignOnButtonTitle: String? {
        return "Single Sign On"
    }

    static let copyrightName = "SAP"
    static var poweredByText: String {
        return "Powered by HPI / openHPI"
    }

}
