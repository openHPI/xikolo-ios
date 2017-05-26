//
//  Brand.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 29.11.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import Foundation
import UIKit

struct Brand {

    static let BaseURL = "https://openwho.org"

    static let TintColor = UIColor(red: 11/255, green: 114/255, blue: 181/255, alpha: 1.0)
    static let TintColorSecond = UIColor(red: 145/255, green: 100/255, blue: 167/255, alpha: 1.0)
    static let TintColorThird = UIColor(red: 167/255, green: 202/255, blue: 108/255, alpha: 1.0)
    static let AppID = "de.xikolo.openwho"
    static let PlatformTitle = "who"

    static let IMPRINT_URL = Brand.BaseURL + "/pages/about"
    static let PRIVACY_URL = Brand.BaseURL + "/pages/terms_of_use"

    static let ButtonLabelSSO = "WHO Identity (WIMS)"
    
}
