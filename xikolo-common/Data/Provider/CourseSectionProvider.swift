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

    class func getCourseSections(_ courseId: String) -> Future<[CourseSectionSpine], XikoloError> {
        var query: Query<CourseSectionSpine> = Query(resourceType: CourseSectionSpine.self)
        query.addPredicateWithKey("course", value: courseId, type: .equalTo)

        return SpineHelper.find(query)
    }

}
