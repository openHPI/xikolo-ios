//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures
import Foundation

struct CourseDateHelper {

    @discardableResult static func syncAllCourseDates() -> Future<SyncEngine.SyncMultipleResult, XikoloError> {
        let query = MultipleResourcesQuery(type: CourseDate.self)
        return SyncHelper.syncResources(withFetchRequest: CourseDateHelper.FetchRequest.allCourseDates, withQuery: query)
    }

    @discardableResult static func syncCourseDates(for course: Course) -> Future<SyncEngine.SyncMultipleResult, XikoloError> {
        let fetchRequest = CourseDateHelper.FetchRequest.courseDates(for: course)
        var query = MultipleResourcesQuery(type: CourseDate.self)
        query.addFilter(forKey: "course", withValue: course.id)
        return SyncHelper.syncResources(withFetchRequest: fetchRequest, withQuery: query)
    }

}
