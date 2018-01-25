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

    static let BaseURL = "https://open.sap.com"
    
    static let TintColor = UIColor(red: 240/255, green: 171/255, blue: 0/255, alpha: 1.0)
    static let TintColorSecond = UIColor(red: 34/255, green: 108/255, blue: 169/255, alpha: 1.0)
    static let TintColorThird = UIColor(red: 138/255, green: 181/255, blue: 78/255, alpha: 1.0)
    static let AppID = "de.xikolo.opensap"
    static let PlatformTitle = "sap"

    static let IMPRINT_URL = "http://www.sap.com/corporate/en/legal/impressum.html"
    static let PRIVACY_URL = "http://www.sap.com/corporate/en/legal/privacy.html"
    
    static let ButtonLabelSSO = "Single Sign On"

    static let FeedbackRecipients = ["mobile-feedback@hpi.de"]
    static let FeedbackSubject = "openSAP | App Feedback"

    static var copyrightText: String {
        let currentYear = Calendar.current.component(.year, from: Date())
        return "Copyright © \(currentYear) SAP. All rights reserved."
    }
    static let poweredByText: String? = "Powered by HPI / openHPI"

    static var locale: Locale = Locale.init(identifier: "en")

}
