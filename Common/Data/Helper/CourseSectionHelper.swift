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

        let config = XikoloSyncConfig()
        let strategy = JsonAPISyncStrategy()
        let engine = SyncEngine(configuration: config, strategy: strategy)
        return engine.syncResources(withFetchRequest: fetchRequest, withQuery: query).mapError { error -> XikoloError in
            return .synchronization(error)
        }
    }

}
