//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures
import Foundation
import Stockpile

public enum CourseSectionHelper {

    public static func syncCourseSections(forCourse course: Course) -> Future<SyncMultipleResult, XikoloError> {
        let fetchRequest = Self.FetchRequest.allCourseSections(forCourse: course)
        var query = MultipleResourcesQuery(type: CourseSection.self)
        query.addFilter(forKey: "course", withValue: course.id)
        return XikoloSyncEngine().synchronize(withFetchRequest: fetchRequest, withQuery: query)
    }

}
