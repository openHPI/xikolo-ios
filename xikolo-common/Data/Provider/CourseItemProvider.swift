//
//  CourseItemProvider.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 13.05.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import BrightFutures
import Foundation
import Spine

class CourseItemProvider {

    class func getCourseItems(sectionId: String) -> Future<[CourseItemSpine], XikoloError> {
        var query = Query(resourceType: CourseItemSpine.self)
        query.filterOn("section", equalTo: sectionId)

        return SpineHelper.find(query)
    }

}
