//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures
import Foundation
import SyncEngine

public enum CourseProgressHelper {

    public static func syncProgress(forCourse course: Course) -> Future<SyncSingleResult, XikoloError> {
        let fetchRequest = Self.FetchRequest.courseProgress(forCourse: course)
        var query = SingleResourceQuery(type: CourseProgress.self, id: course.id)
        query.include("section-progresses")
        return XikoloSyncEngine().synchronize(withFetchRequest: fetchRequest, withQuery: query)
    }

}
