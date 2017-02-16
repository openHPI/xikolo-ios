//
//  CourseDateProvider.swift
//  xikolo-ios
//
//  Created by Tobias Rohloff on 11.11.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import BrightFutures
import Foundation

class CourseDateProvider {

    class func getCourseDates() -> Future<[CourseDateSpine], XikoloError> {
        return SpineHelper.findAll(CourseDateSpine.self)
    }
    
}
