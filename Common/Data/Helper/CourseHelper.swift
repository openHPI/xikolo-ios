//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures
import Foundation
import Stockpile

public enum CourseHelper {

    @discardableResult public static func syncAllCourses() -> Future<SyncMultipleResult, XikoloError> {
        var query = MultipleResourcesQuery(type: Course.self)
        query.include("channel")
        query.include("user_enrollment")
        return XikoloSyncEngine().synchronize(withFetchRequest: Self.FetchRequest.allCourses, withQuery: query)
    }

    @discardableResult public static func syncCourse(_ course: Course) -> Future<SyncSingleResult, XikoloError> {
        var query = SingleResourceQuery(resource: course)
        query.include("channel")
        query.include("user_enrollment")
        return XikoloSyncEngine().synchronize(withFetchRequest: Self.FetchRequest.course(withId: course.id), withQuery: query)
    }

    @discardableResult public static func syncCourse(forSlugOrId slugOrId: String) -> Future<SyncSingleResult, XikoloError> {
        var query = SingleResourceQuery(type: Course.self, id: slugOrId)
        query.include("channel")
        query.include("user_enrollment")
        return XikoloSyncEngine().synchronize(withFetchRequest: Self.FetchRequest.course(withSlugOrId: slugOrId), withQuery: query)
    }

    public static func visit(_ course: Course) {
        let courseObjectId = course.objectID
        CoreDataHelper.persistentContainer.performBackgroundTask { context in
            let backgroundCourse = context.existingTypedObject(with: courseObjectId) as? Course
            backgroundCourse?.lastVisited = Date()
            try? context.save()
        }
    }

}
