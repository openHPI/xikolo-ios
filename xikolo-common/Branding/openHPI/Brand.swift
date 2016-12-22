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

    #if DEBUG
    static let BaseURL = "https://staging.openhpi.de"
    #else
    static let BaseURL = "https://open.hpi.de"
    #endif

    static let TintColor = UIColor.init(red: 222/255, green: 98/255, blue: 18/255, alpha: 1.0)
    static let AppID = "de.xikolo.openhpi"

}
