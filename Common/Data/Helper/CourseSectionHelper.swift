//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures
import Foundation

struct CourseSectionHelper {

    static func syncCourseSections(forCourse course: Course) -> Future<SyncEngine.SyncMultipleResult, XikoloError> {
        let fetchRequest = CourseSectionHelper.FetchRequest.allCourseSections(forCourse: course)
        var query = MultipleResourcesQuery(type: CourseSection.self)
        query.addFilter(forKey: "course", withValue: course.id)
        return SyncEngine.shared.syncResources(withFetchRequest: fetchRequest, withQuery: query)
    }

}
