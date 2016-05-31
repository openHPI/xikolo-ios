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

    class func getCourseSections(courseId: String, completionHandler: (sections: [CourseSectionSpine]?, error: ErrorType?) -> ()) {
        let spine = Spine(baseURL: NSURL(string: Routes.API_V2_URL)!)
        spine.registerResource(CourseSectionSpine)

        var query = Query(resourceType: CourseSectionSpine.self)
        query.filterOn("course", equalTo: courseId)

        spine.find(query).onSuccess { resources, meta, jsonapi in
            // TODO: Pagination?
            completionHandler(sections: resources.map { $0 as! CourseSectionSpine }, error: nil)
        }.onFailure { error in
            completionHandler(sections: nil, error: error)
        }
    }

}
