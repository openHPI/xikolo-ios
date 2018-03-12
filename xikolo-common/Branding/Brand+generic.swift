//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

extension Brand {

    static let FlagUpcomingColor = UIColor(red: 20/255, green: 136/255, blue: 255/255, alpha: 1.0)
    static let FlagSelfpacedColor = UIColor(red: 245/255, green: 167/255, blue: 4/255, alpha: 1.0)
    static let FlagRunningColor = UIColor(red: 140/255, green: 179/255, blue: 13/255, alpha: 1.0)

    static let CorrectAnswerColor = UIColor(red: 140 / 255, green: 179 / 255, blue: 13 / 255, alpha: 1)
    static let IncorrectAnswerColor = UIColor(red: 214 / 255, green: 0 / 255, blue: 26 / 255, alpha: 1)
    static let WrongAnswerColor = UIColor(red: 187 / 255, green: 188 / 255, blue: 190 / 255, alpha: 1)

    static let APP_IMPRINT_URL = IMPRINT_URL + "?in_app=true"
    static let APP_PRIVACY_URL = PRIVACY_URL + "?in_app=true"
    static let APP_GITHUB_URL = "https://github.com/openHPI/xikolo-ios"
    
    static var host: String {
        let url = URL(string: self.BaseURL).require(hint: "Invalid base URL")
        return url.host.require(hint: "Invalid base URL - Unable to find host")
    }

    static var locale: Locale = Bundle.main.localizations.contains(Locale.current.languageCode ?? Locale.current.identifier) ? Locale.current : Locale.init(identifier: "en")

    static var windowTintColor: UIColor {
        #if OPENSAP
            return self.TintColorSecond
        #else
            return self.TintColor
        #endif
    }

}
