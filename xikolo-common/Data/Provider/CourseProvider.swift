//
//  CourseProvider.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 22.04.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import BrightFutures
import Foundation
import Spine

class CourseProvider {

    class func getCourses() -> Future<[CourseSpine], XikoloError> {
        let spine = SpineModelHelper.createSpineClient()
        spine.registerResource(CourseSpine)
        spine.registerResource(CourseEnrollmentSpine)

        return spine.findAll(CourseSpine.self).map { tuple in
            tuple.resources.map { $0 as! CourseSpine }
        }.mapError { error in
            XikoloError.API(error)
        }
    }

}
