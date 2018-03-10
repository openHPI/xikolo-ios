//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation
import CoreData
import BrightFutures

struct CourseSectionHelper {

    static func syncCourseSections(forCourse course: Course) -> Future<SyncEngine.SyncMultipleResult, XikoloError> {
        let fetchRequest = CourseSectionHelper.FetchRequest.allCourseSections(forCourse: course)
        var query = MultipleResourcesQuery(type: CourseSection.self)
        query.addFilter(forKey: "course", withValue: course.id)
        return SyncHelper.syncResources(withFetchRequest: fetchRequest, withQuery: query)
    }

}
