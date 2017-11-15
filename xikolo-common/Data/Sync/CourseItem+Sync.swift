//
//  CourseItem+Sync.swift
//  xikolo-ios
//
//  Created by Max Bothe on 15.11.17.
//  Copyright © 2017 HPI. All rights reserved.
//

import Foundation
import BrightFutures

extension CourseItem {

    static func syncCourseItems(forSection section: CourseSection) -> Future<[CourseItem], XikoloError> {
        let fetchRequest = CourseItem.FetchRequest.courseItems(forSection: section)
        var query = MultipleResourcesQuery(type: CourseItem.self)
        query.addFilter(forKey: "section", withValue: section.id)
        return SyncEngine.syncResources(withFetchRequest: fetchRequest, withQuery: query)
    }

    static func syncCourseItems(forCourse course: Course) -> Future<[[CourseItem]], XikoloError> {
        return CourseSection.syncCourseSections(forCourse: course).flatMap { sections in
            return sections.traverse { section in
                CourseItem.syncCourseItems(forSection: section)
            }
        }
    }

    static func syncRichTexts(forCourse course: Course) -> Future<[CourseItem], XikoloError> {
        let fetchRequest = CourseItem.FetchRequest.courseItems(forCourse: course, withType: "rich_text")
        var query = MultipleResourcesQuery(type: CourseItem.self)
        query.addFilter(forKey: "course", withValue: course.id)
        query.addFilter(forKey: "content_type", withValue: "rich_text")
        query.include("content")
        return SyncEngine.syncResources(withFetchRequest: fetchRequest, withQuery: query)
    }

    static func syncVideos(forCourse course: Course) -> Future<[CourseItem], XikoloError> {
        let fetchRequest = CourseItem.FetchRequest.courseItems(forCourse: course, withType: "video")
        var query = MultipleResourcesQuery(type: CourseItem.self)
        query.addFilter(forKey: "course", withValue: course.id)
        query.addFilter(forKey: "content_type", withValue: "video")
        query.include("content")
        return SyncEngine.syncResources(withFetchRequest: fetchRequest, withQuery: query)
    }

}
