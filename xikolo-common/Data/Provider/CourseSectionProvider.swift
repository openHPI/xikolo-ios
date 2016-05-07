//
//  CourseSectionProvider.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 04.05.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import Foundation
import Spine

class CourseSectionProvider {

    class func getCourseSections(courseId: String, completionHandler: (courses: [CourseSectionSpine]?, error: ErrorType?) -> ()) {
        let spine = Spine(baseURL: NSURL(string: Routes.API_URL)!)
        spine.registerResource(CourseSectionSpine)

        var query = Query(resourceType: CourseSectionSpine.self, path: Routes.COURSE_SECTIONS)
        query.filterOn("course_id", equalTo: courseId)

        spine.find(query).onSuccess { resources, meta, jsonapi in
            // TODO: Pagination?
            completionHandler(courses: resources.map { $0 as! CourseSectionSpine }, error: nil)
        }.onFailure { error in
            completionHandler(courses: nil, error: error)
        }
    }

}
