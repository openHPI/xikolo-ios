//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation
import CoreData
import BrightFutures

struct CourseHelper {

    @discardableResult static func syncAllCourses() -> Future<SyncEngine.SyncMultipleResult, XikoloError> {
        var query = MultipleResourcesQuery(type: Course.self)
        query.include("channel")
        query.include("user_enrollment")
        return SyncHelper.syncResources(withFetchRequest: CourseHelper.FetchRequest.allCourses, withQuery: query)
    }

    @discardableResult static func syncCourse(_ course: Course) -> Future<SyncEngine.SyncSingleResult, XikoloError> {
        var query = SingleResourceQuery(resource: course)
        query.include("channel")
        query.include("user_enrollment")
        return SyncHelper.syncResource(withFetchRequest: CourseHelper.FetchRequest.course(withId: course.id), withQuery: query)
    }

    @discardableResult static func syncCourse(forSlugOrId slugOrId: String) -> Future<SyncEngine.SyncSingleResult, XikoloError> {
        var query = SingleResourceQuery(type: Course.self, id: slugOrId)
        query.include("channel")
        query.include("user_enrollment")
        return SyncHelper.syncResource(withFetchRequest: CourseHelper.FetchRequest.course(withSlugOrId: slugOrId), withQuery: query)
    }

}
