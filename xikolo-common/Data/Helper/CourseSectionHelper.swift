//
//  CourseSectionHelper.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 11.05.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import Foundation
import CoreData
import BrightFutures

struct CourseSectionHelper {

    static func syncCourseSections(forCourse course: Course) -> Future<[NSManagedObjectID], XikoloError> {
        let fetchRequest = CourseSectionHelper.FetchRequest.allCourseSections(forCourse: course)
        var query = MultipleResourcesQuery(type: CourseSection.self)
        query.addFilter(forKey: "course", withValue: course.id)
        return SyncEngine.syncResources(withFetchRequest: fetchRequest, withQuery: query)
    }

}
