//
//  Brand.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 20.07.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import Foundation
import UIKit

struct Brand {

    static let BaseURL = "https://open.hpi.de"

    static let TintColor = UIColor(red: 222/255, green: 98/255, blue: 18/255, alpha: 1.0)
    static let TintColorSecond = UIColor(red: 180/255, green: 41/255, blue: 70/255, alpha: 1.0)
    static let TintColorThird = UIColor(red: 245/255, green: 167/255, blue: 4/255, alpha: 1.0)
    static let AppID = "de.xikolo.openhpi"
    static let PlatformTitle = "hpi"

    static let IMPRINT_URL = Brand.BaseURL + "/pages/imprint"
    static let PRIVACY_URL = Brand.BaseURL + "/pages/privacy"

    static let FeedbackRecipients = ["mobile-feedback@hpi.de"]
    static let FeedbackSubject = "openHPI | App Feedback"

    static var copyrightText: String {
        let currentYear = Calendar.current.component(.year, from: Date())
        return "Copyright © \(currentYear) HPI. All rights reserved."
    }
    static let poweredByText: String? = nil

    static var locale: Locale = Locale.autoupdatingCurrent

}
