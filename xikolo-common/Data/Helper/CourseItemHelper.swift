//
//  CourseItemHelper.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 13.05.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import Foundation
import CoreData
import BrightFutures

struct CourseItemHelper {

    static func syncCourseItems(forSection section: CourseSection) -> Future<[NSManagedObjectID], XikoloError> {
        let fetchRequest = CourseItemHelper.FetchRequest.orderedCourseItems(forSection: section)
        var query = MultipleResourcesQuery(type: CourseItem.self)
        query.addFilter(forKey: "section", withValue: section.id)
        return SyncEngine.syncResources(withFetchRequest: fetchRequest, withQuery: query)
    }

    static func syncCourseItems(forCourse course: Course) -> Future<[[NSManagedObjectID]], XikoloError> {
        return CourseSectionHelper.syncCourseSections(forCourse: course).flatMap { sectionObjectIds in
            return sectionObjectIds.flatMap { sectionObjectId -> Future<[NSManagedObjectID], XikoloError> in
                let promise = Promise<[NSManagedObjectID], XikoloError>()

                CoreDataHelper.persistentContainer.performBackgroundTask { context in
                    let courseSection = context.typedObject(with: sectionObjectId) as CourseSection
                    let courseItemsFuture = CourseItemHelper.syncCourseItems(forSection: courseSection)
                    promise.completeWith(courseItemsFuture)
                }

                return promise.future
            }.sequence()
        }
    }

    static func syncRichTexts(forCourse course: Course) -> Future<[NSManagedObjectID], XikoloError> {
        let fetchRequest = CourseItemHelper.FetchRequest.courseItems(forCourse: course, withType: "rich_text")
        var query = MultipleResourcesQuery(type: CourseItem.self)
        query.addFilter(forKey: "course", withValue: course.id)
        query.addFilter(forKey: "content_type", withValue: "rich_text")
        query.include("content")
        return SyncEngine.syncResources(withFetchRequest: fetchRequest, withQuery: query, deleteNotExistingResources: false)
    }

    static func syncVideos(forCourse course: Course) -> Future<[NSManagedObjectID], XikoloError> {
        let fetchRequest = CourseItemHelper.FetchRequest.courseItems(forCourse: course, withType: "video")
        var query = MultipleResourcesQuery(type: CourseItem.self)
        query.addFilter(forKey: "course", withValue: course.id)
        query.addFilter(forKey: "content_type", withValue: "video")
        query.include("content")
        return SyncEngine.syncResources(withFetchRequest: fetchRequest, withQuery: query, deleteNotExistingResources: false)
    }

    static func syncCourseItemWithContent(_ courseItem: CourseItem) -> Future<NSManagedObjectID, XikoloError> {
        let fetchRequest = CourseItemHelper.FetchRequest.courseItem(withId: courseItem.id)
        var query = SingleResourceQuery(resource: courseItem)
        query.include("content")
        return SyncEngine.syncResource(withFetchRequest: fetchRequest, withQuery: query)
    }

    static func markAsVisited(_ item: CourseItem) -> Future<Void, XikoloError> {
        guard !item.visited else {
            return Future(value: ())
        }

        let promise = Promise<Void, XikoloError>()

        CoreDataHelper.persistentContainer.performBackgroundTask { context in
            guard let courseItem = context.existingTypedObject(with: item.objectID) as? CourseItem else {
                promise.failure(.missingResource(ofType: CourseItem.self))
                return
            }

            courseItem.visited = true
            courseItem.objectState = .modified
            promise.complete(context.saveWithResult())
        }

        return promise.future
    }

}
