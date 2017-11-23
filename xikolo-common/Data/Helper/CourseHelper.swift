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

    static func syncAllCourses() -> Future<[NSManagedObjectID], XikoloError> {
        var query = MultipleResourcesQuery(type: Course.self)
        query.include("channel")
        query.include("user_enrollment")
        return SyncEngine.syncResources(withFetchRequest: CourseHelper.FetchRequest.allCourses, withQuery: query)
    }

    static func syncCourse(_ course: Course) -> Future<NSManagedObjectID, XikoloError> {
        var query = SingleResourceQuery(resource: course)
        query.include("channel")
        query.include("user_enrollment")
        return SyncEngine.syncResource(withFetchRequest: CourseHelper.FetchRequest.course(withId: course.id), withQuery: query)
    }

}
