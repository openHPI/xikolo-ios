//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures
import Foundation

struct CourseItemHelper {

    static func syncCourseItems(forSection section: CourseSection) -> Future<SyncEngine.SyncMultipleResult, XikoloError> {
        let fetchRequest = CourseItemHelper.FetchRequest.orderedCourseItems(forSection: section)
        var query = MultipleResourcesQuery(type: CourseItem.self)
        query.addFilter(forKey: "section", withValue: section.id)
        return SyncHelper.syncResources(withFetchRequest: fetchRequest, withQuery: query)
    }

    static func syncCourseItems(forCourse course: Course) -> Future<[SyncEngine.SyncMultipleResult], XikoloError> {
        return CourseSectionHelper.syncCourseSections(forCourse: course).flatMap { sectionObjectIds in
            return sectionObjectIds.objectIds.flatMap { sectionObjectId -> Future<SyncEngine.SyncMultipleResult, XikoloError> in
                let promise = Promise<SyncEngine.SyncMultipleResult, XikoloError>()

                CoreDataHelper.persistentContainer.performBackgroundTask { context in
                    let courseSection = context.typedObject(with: sectionObjectId) as CourseSection
                    let courseItemsFuture = CourseItemHelper.syncCourseItems(forSection: courseSection)
                    promise.completeWith(courseItemsFuture)
                }

                return promise.future
            }.sequence()
        }
    }

    @discardableResult static func syncCourseItems(forCourse course: Course, withContentType type: String) -> Future<SyncEngine.SyncMultipleResult, XikoloError> {
        let fetchRequest = CourseItemHelper.FetchRequest.courseItems(forCourse: course, withContentType: type)
        var query = MultipleResourcesQuery(type: CourseItem.self)
        query.addFilter(forKey: "course", withValue: course.id)
        query.addFilter(forKey: "content_type", withValue: type)
        query.include("content")
        return SyncHelper.syncResources(withFetchRequest: fetchRequest, withQuery: query, deleteNotExistingResources: false)
    }

    @discardableResult static func syncCourseItems(forSection section: CourseSection, withContentType type: String) -> Future<SyncEngine.SyncMultipleResult, XikoloError> {
        let fetchRequest = CourseItemHelper.FetchRequest.courseItems(forSection: section, withContentType: type)
        var query = MultipleResourcesQuery(type: CourseItem.self)
        query.addFilter(forKey: "section", withValue: section.id)
        query.addFilter(forKey: "content_type", withValue: type)
        query.include("content")
        return SyncHelper.syncResources(withFetchRequest: fetchRequest, withQuery: query, deleteNotExistingResources: false)
    }

    @discardableResult static func syncCourseItemWithContent(_ courseItem: CourseItem) -> Future<SyncEngine.SyncSingleResult, XikoloError> {
        let fetchRequest = CourseItemHelper.FetchRequest.courseItem(withId: courseItem.id)
        var query = SingleResourceQuery(resource: courseItem)
        query.include("content")
        return SyncHelper.syncResource(withFetchRequest: fetchRequest, withQuery: query)
    }

    @discardableResult static func markAsVisited(_ item: CourseItem) -> Future<Void, XikoloError> {
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
