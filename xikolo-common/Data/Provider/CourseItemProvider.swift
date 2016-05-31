//
//  CourseItemProvider.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 13.05.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import Foundation
import Spine

class CourseItemProvider {

    class func getCourseItems(sectionId: String, completionHandler: (items: [CourseItemSpine]?, error: ErrorType?) -> ()) {
        let spine = Spine(baseURL: NSURL(string: Routes.API_V2_URL)!)
        spine.registerResource(CourseItemSpine)
        spine.registerResource(QuizSpine)
        spine.registerResource(RichTextSpine)
        spine.registerResource(VideoSpine)

        var query = Query(resourceType: CourseItemSpine.self)
        query.filterOn("section", equalTo: sectionId)

        spine.find(query).onSuccess { resources, meta, jsonapi in
            // TODO: Pagination?
            completionHandler(items: resources.map { $0 as! CourseItemSpine }, error: nil)
        }.onFailure { error in
            completionHandler(items: nil, error: error)
        }
    }

}
