//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures
import Foundation
import SyncEngine

struct CourseSectionHelper {

    static func syncCourseSections(forCourse course: Course) -> Future<SyncMultipleResult, XikoloError> {
        let fetchRequest = CourseSectionHelper.FetchRequest.allCourseSections(forCourse: course)
        var query = MultipleResourcesQuery(type: CourseSection.self)
        query.addFilter(forKey: "course", withValue: course.id)

        let engine = XikoloSyncEngine()
        return engine.syncResources(withFetchRequest: fetchRequest, withQuery: query)
    }

}
