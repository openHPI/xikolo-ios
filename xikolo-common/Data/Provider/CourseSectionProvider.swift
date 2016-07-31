//
//  CourseSectionProvider.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 04.05.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import BrightFutures
import Foundation
import Spine

class CourseSectionProvider {

    class func getCourseSections(courseId: String) -> Future<[CourseSectionSpine], XikoloError> {
        let spine = SpineModelHelper.createSpineClient()
        spine.registerResource(CourseSectionSpine)

        var query: Query<CourseSectionSpine> = Query(resourceType: CourseSectionSpine.self)
        query.filterOn("course", equalTo: courseId)

        return spine.find(query).map { tuple in
            tuple.resources.map { $0 as! CourseSectionSpine }
        }.mapError { error in
            XikoloError.API(error)
        }
    }

}
