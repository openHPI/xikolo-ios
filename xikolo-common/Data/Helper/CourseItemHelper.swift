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

    static private let entity = NSEntityDescription.entityForName("CourseItem", inManagedObjectContext: CoreDataHelper.managedContext)!

    static func getItemRequest(section: CourseSection) -> NSFetchRequest {
        let request = NSFetchRequest(entityName: "CourseItem")
        request.predicate = NSPredicate(format: "section = %@", section)
        let titleSort = NSSortDescriptor(key: "position", ascending: true)
        request.sortDescriptors = [titleSort]
        return request
    }
    
    static func getItemRequest(course: Course) -> NSFetchRequest {
        let request = NSFetchRequest(entityName: "CourseItem")
        request.predicate = NSPredicate(format: "section.course = %@", course)
        let sectionSort = NSSortDescriptor(key: "section.position", ascending: true)
        let positionSort = NSSortDescriptor(key: "position", ascending: true)
        request.sortDescriptors = [sectionSort, positionSort]
        return request
    }

    static func syncCourseItems(section: CourseSection) -> Future<[CourseItem], XikoloError> {
        return CourseItemProvider.getCourseItems(section.id).flatMap { spineItems -> Future<[BaseModel], XikoloError> in
            let request = getItemRequest(section)
            return SpineModelHelper.syncObjectsFuture(request, spineObjects: spineItems, inject: ["section": section], save: true)
        }.map { cdItems in
            return cdItems as! [CourseItem]
        }
    }

}
