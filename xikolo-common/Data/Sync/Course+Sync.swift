//
//  Course+Sync.swift
//  xikolo-ios
//
//  Created by Max Bothe on 15.11.17.
//  Copyright © 2017 HPI. All rights reserved.
//

import Foundation
import BrightFutures

extension Course {

    static func syncAllCourses() -> Future<[Course], XikoloError> {
        var query = MultipleResourcesQuery(type: Course.self)
        query.include("channel")
        query.include("user_enrollment")
        return SyncEngine.syncResources(withFetchRequest: Course.FetchRequest.allCourses, withQuery: query)
    }

    static func syncCourse(_ course: Course) -> Future<Course, XikoloError> {
        var query = SingleResourceQuery(resource: course)
        query.include("channel")
        query.include("user_enrollment")
        return SyncEngine.syncResource(withFetchRequest: Course.FetchRequest.course(withId: course.id), withQuery: query)
    }

}
