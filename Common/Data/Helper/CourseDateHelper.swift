//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures
import Foundation
import SyncEngine

public struct CourseDateHelper {

    @discardableResult public static func syncAllCourseDates() -> Future<SyncMultipleResult, XikoloError> {
        let query = MultipleResourcesQuery(type: CourseDate.self)

        let engine = XikoloSyncEngine()
        return engine.syncResources(withFetchRequest: CourseDateHelper.FetchRequest.allCourseDates, withQuery: query)
    }

    @discardableResult public static func syncCourseDates(for course: Course) -> Future<SyncMultipleResult, XikoloError> {
        let fetchRequest = CourseDateHelper.FetchRequest.courseDates(for: course)
        var query = MultipleResourcesQuery(type: CourseDate.self)
        query.addFilter(forKey: "course", withValue: course.id)

        let engine = XikoloSyncEngine()
        return engine.syncResources(withFetchRequest: fetchRequest, withQuery: query)
    }

}
