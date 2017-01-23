//
//  PlatformEventProvider.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 07.09.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import BrightFutures
import Foundation
import Spine

class PlatformEventProvider {

    class func getPlatformEvents() -> Future<[PlatformEventSpine], XikoloError> {
        return SpineHelper.findAll(PlatformEventSpine.self)
    }
    
}
