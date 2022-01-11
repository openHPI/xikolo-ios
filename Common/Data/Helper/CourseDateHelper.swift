//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures
import Foundation
import Stockpile

public enum CourseDateHelper {

    @discardableResult public static func syncAllCourseDates() -> Future<SyncMultipleResult, XikoloError> {
        let query = MultipleResourcesQuery(type: CourseDate.self)
        return XikoloSyncEngine().synchronize(withFetchRequest: CourseDate.fetchRequest(), withQuery: query)
    }

    @discardableResult public static func syncCourseDates(for course: Course) -> Future<SyncMultipleResult, XikoloError> {
        let fetchRequest = Self.FetchRequest.courseDates(for: course)
        var query = MultipleResourcesQuery(type: CourseDate.self)
        query.addFilter(forKey: "course", withValue: course.id)
        return XikoloSyncEngine().synchronize(withFetchRequest: fetchRequest, withQuery: query)
    }

}
