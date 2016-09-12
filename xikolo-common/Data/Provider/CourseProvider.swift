//
//  CourseProvider.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 22.04.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import BrightFutures
import Foundation

class CourseProvider {

    class func getCourses() -> Future<[CourseSpine], XikoloError> {
        return SpineHelper.findAll(CourseSpine.self)
    }

}
