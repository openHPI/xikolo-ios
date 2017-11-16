//
//  CourseItemHelper.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 13.05.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import Foundation
import BrightFutures

struct CourseItemHelper {

    static func syncCourseItems(forSection section: CourseSection) -> Future<[CourseItem], XikoloError> {
        let fetchRequest = CourseItemHelper.FetchRequest.courseItems(forSection: section)
        var query = MultipleResourcesQuery(type: CourseItem.self)
        query.addFilter(forKey: "section", withValue: section.id)
        return SyncEngine.syncResources(withFetchRequest: fetchRequest, withQuery: query)
    }

    static func syncCourseItems(forCourse course: Course) -> Future<[[CourseItem]], XikoloError> {
        return CourseSectionHelper.syncCourseSections(forCourse: course).flatMap { sections in
            return sections.traverse { section in
                CourseItemHelper.syncCourseItems(forSection: section)
            }
        }
    }

    static func syncRichTexts(forCourse course: Course) -> Future<[CourseItem], XikoloError> {
        let fetchRequest = CourseItemHelper.FetchRequest.courseItems(forCourse: course, withType: "rich_text")
        var query = MultipleResourcesQuery(type: CourseItem.self)
        query.addFilter(forKey: "course", withValue: course.id)
        query.addFilter(forKey: "content_type", withValue: "rich_text")
        query.include("content")
        return SyncEngine.syncResources(withFetchRequest: fetchRequest, withQuery: query)
    }

    static func syncVideos(forCourse course: Course) -> Future<[CourseItem], XikoloError> {
        let fetchRequest = CourseItemHelper.FetchRequest.courseItems(forCourse: course, withType: "video")
        var query = MultipleResourcesQuery(type: CourseItem.self)
        query.addFilter(forKey: "course", withValue: course.id)
        query.addFilter(forKey: "content_type", withValue: "video")
        query.include("content")
        return SyncEngine.syncResources(withFetchRequest: fetchRequest, withQuery: query)
    }

}


//import BrightFutures
//import CoreData
//
//class CourseItemHelper {
//
//    static func getItemRequest(_ section: CourseSection) -> NSFetchRequest<CourseItem> {
//        let request: NSFetchRequest<CourseItem> = CourseItem.fetchRequest()
//        request.predicate = NSPredicate(format: "section = %@", section)
//        let titleSort = NSSortDescriptor(key: "position", ascending: true)
//        request.sortDescriptors = [titleSort]
//        return request
//    }
//    
//    static func getItemRequest(_ course: Course) -> NSFetchRequest<CourseItem> {
//        let request: NSFetchRequest<CourseItem> = CourseItem.fetchRequest()
//        request.predicate = NSPredicate(format: "section.course = %@", course)
//        let sectionSort = NSSortDescriptor(key: "section.position", ascending: true)
//        let positionSort = NSSortDescriptor(key: "position", ascending: true)
//        request.sortDescriptors = [sectionSort, positionSort]
//        return request
//    }
//
//    static func getByID(_ id: String) throws -> CourseItem? {
//        let request: NSFetchRequest<CourseItem> = CourseItem.fetchRequest()
//        request.predicate = NSPredicate(format: "id == %@", id)
//        request.fetchLimit = 1
//        let courseItems = try CoreDataHelper.executeFetchRequest(request)
//        return courseItems.first
//    }
//
//    static func syncCourseItems(_ section: CourseSection) -> Future<[CourseItem], XikoloError> {
//        return CourseItemProvider.getCourseItems(section.id).flatMap { spineItems -> Future<[CourseItem], XikoloError> in
//            let request = getItemRequest(section)
//            return SpineModelHelper.syncObjectsFuture(request, spineObjects: spineItems, inject: ["section": section], save: true)
//        }
//    }
//
//    static func syncRichTextsFor(course: Course) -> Future<[CourseItem], XikoloError> {
//        return CourseItemProvider.getRichTextsFor(course: course).flatMap { spineItems -> Future<[CourseItem], XikoloError> in
//            let richTextRequest: NSFetchRequest<RichText> = RichText.fetchRequest()
//            richTextRequest.predicate = NSPredicate(format: "item.section.course == %@", course)
//            do {
//                let richTexts = try CoreDataHelper.executeFetchRequest(richTextRequest)
//                let request: NSFetchRequest<CourseItem> = CourseItem.fetchRequest()
//                request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
//                    NSPredicate(format: "section.course == %@", course),
//                    NSPredicate(format: "content in %@", richTexts),
//                ])
//                return SpineModelHelper.syncObjectsFuture(request, spineObjects: spineItems, inject: nil, save: true)
//            } catch let error as NSError {
//                return Future(error: XikoloError.coreData(error))
//            }
//        }
//    }
//
//    static func syncVideosFor(course: Course) -> Future<[CourseItem], XikoloError> {
//        return CourseItemProvider.getVideosFor(course: course).flatMap { spineItems -> Future<[CourseItem], XikoloError> in
//            let videoRequest: NSFetchRequest<Video> = Video.fetchRequest()
//            videoRequest.predicate = NSPredicate(format: "item.section.course == %@", course)
//            do {
//                let videos = try CoreDataHelper.executeFetchRequest(videoRequest)
//                let request: NSFetchRequest<CourseItem> = CourseItem.fetchRequest()
//                request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
//                    NSPredicate(format: "section.course == %@", course),
//                    NSPredicate(format: "content in %@", videos),
//                ])
//                return SpineModelHelper.syncObjectsFuture(request, spineObjects: spineItems, inject: nil, save: true)
//            } catch let error as NSError {
//                return Future(error: XikoloError.coreData(error))
//            }
//        }
//    }
//
//}

