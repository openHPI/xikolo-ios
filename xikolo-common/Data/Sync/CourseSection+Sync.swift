//
//  CourseSection+Sync.swift
//  xikolo-ios
//
//  Created by Max Bothe on 15.11.17.
//  Copyright © 2017 HPI. All rights reserved.
//

import Foundation
import BrightFutures

extension CourseSection {

    static func syncCourseSections(forCourse course: Course) -> Future<[CourseSection], XikoloError> {
        let fetchRequest = CourseSection.FetchRequest.courseSections(forCourse: course)
        var query = MultipleResourcesQuery(type: CourseSection.self)
        query.addFilter(forKey: "course", withValue: course.id)
        return SyncEngine.syncResources(withFetchRequest: fetchRequest, withQuery: query)
    }

}
