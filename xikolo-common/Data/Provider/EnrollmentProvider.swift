//
//  CourseEnrollmentProvider.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 16.03.17.
//  Copyright © 2017 HPI. All rights reserved.
//

import BrightFutures
import Foundation

class EnrollmentProvider {

    class func getEnrollments() -> Future<[EnrollmentSpine], XikoloError> {
        return SpineHelper.findAll(EnrollmentSpine.self)
    }

}
