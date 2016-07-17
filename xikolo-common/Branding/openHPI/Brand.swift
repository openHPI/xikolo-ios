//
//  Brand.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 20.07.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import Foundation

struct Brand {

    #if DEBUG
    static let BASE_URL = "https://staging.openhpi.de"
    #else
    static let BASE_URL = "https://open.hpi.de"
    #endif

}
