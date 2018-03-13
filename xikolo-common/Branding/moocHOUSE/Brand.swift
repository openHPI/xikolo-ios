//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation
import UIKit

struct Brand {

    static let BaseURL = "https://mooc.house"

    static let TintColor = UIColor(red: 171 / 255, green: 179 / 255, blue: 36 / 255, alpha: 1.0)
    static let TintColorSecond = UIColor(red: 171 / 255, green: 179 / 255, blue: 36 / 255, alpha: 1.0)
    static let TintColorThird = UIColor(red: 171 / 255, green: 179 / 255, blue: 36 / 255, alpha: 1.0)
    static let AppID = "de.xikolo.moochouse"
    static let PlatformTitle = "moochouse"

    static let IMPRINT_URL = Brand.BaseURL + "/pages/imprint"
    static let PRIVACY_URL = Brand.BaseURL + "/pages/privacy"

    static let FeedbackRecipients = ["mobile-feedback@hpi.de"]
    static let FeedbackSubject = "mooc.house | App Feedback"

    static var copyrightText: String {
        let currentYear = Calendar.current.component(.year, from: Date())
        return "Copyright © \(currentYear) HPI. All rights reserved."
    }

    static let poweredByText: String? = nil

}
