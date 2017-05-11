//
//  CourseItemHelper.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 13.05.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import BrightFutures
import CoreData
import Result

class CourseItemHelper {

    static func getItemRequest(_ section: CourseSection) -> NSFetchRequest<NSFetchRequestResult> {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CourseItem")
        request.predicate = NSPredicate(format: "section = %@", section)
        let titleSort = NSSortDescriptor(key: "position", ascending: true)
        request.sortDescriptors = [titleSort]
        return request
    }
    
    static func getItemRequest(_ course: Course) -> NSFetchRequest<NSFetchRequestResult> {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CourseItem")
        request.predicate = NSPredicate(format: "section.course = %@", course)
        let sectionSort = NSSortDescriptor(key: "section.position", ascending: true)
        let positionSort = NSSortDescriptor(key: "position", ascending: true)
        request.sortDescriptors = [sectionSort, positionSort]
        return request
    }

    static func getByID(_ id: String) throws -> CourseItem? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CourseItem")
        request.predicate = NSPredicate(format: "id == %@", id)
        request.fetchLimit = 1
        let courseItems = try CoreDataHelper.executeFetchRequest(request) as! [CourseItem]
        if courseItems.isEmpty {
            return nil
        }
        return courseItems[0]
    }

    static func syncCourseItems(_ section: CourseSection) -> Future<[CourseItem], XikoloError> {
        return CourseItemProvider.getCourseItems(section.id).flatMap { spineItems -> Future<[BaseModel], XikoloError> in
            let request = getItemRequest(section)
            return SpineModelHelper.syncObjectsFuture(request, spineObjects: spineItems, inject: ["section": section], save: true)
        }.map { cdItems in
            return cdItems as! [CourseItem]
        }
    }

}
