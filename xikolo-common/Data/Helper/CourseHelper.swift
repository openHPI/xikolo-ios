//
//  CourseHelper.swift
//  xikolo-ios
//
//  Created by Jonas Müller on 30.09.15.
//  Copyright © 2015 HPI. All rights reserved.
//

import Foundation
import CoreData
import BrightFutures

struct CourseHelper {

    static func syncAllCourses() -> Future<SyncEngine.SyncMultipleResult, XikoloError> {
        var query = MultipleResourcesQuery(type: Course.self)
        query.include("channel")
        query.include("user_enrollment")
        return SyncHelper.syncResources(withFetchRequest: CourseHelper.FetchRequest.allCourses, withQuery: query)
    }

    static func syncCourse(_ course: Course) -> Future<SyncEngine.SyncSingleResult, XikoloError> {
        var query = SingleResourceQuery(resource: course)
        query.include("channel")
        query.include("user_enrollment")
        return SyncHelper.syncResource(withFetchRequest: CourseHelper.FetchRequest.course(withId: course.id), withQuery: query)
    }

    static func syncCourse(forSlugOrId slugOrId: String) -> Future<SyncEngine.SyncSingleResult, XikoloError> {
        var query = SingleResourceQuery(type: Course.self, id: slugOrId)
        query.include("channel")
        query.include("user_enrollment")
        return SyncHelper.syncResource(withFetchRequest: CourseHelper.FetchRequest.course(withSlugOrId: slugOrId), withQuery: query)
    }

}
