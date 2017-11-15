//
//  CourseItem+FetchRequests.swift
//  xikolo-ios
//
//  Created by Max Bothe on 15.11.17.
//  Copyright © 2017 HPI. All rights reserved.
//

import CoreData

extension CourseItem {

    struct FetchRequest {

        static func courseItems(forSection section: CourseSection) -> NSFetchRequest<CourseItem> {
            let request: NSFetchRequest<CourseItem> = CourseItem.fetchRequest()
            request.predicate = NSPredicate(format: "section = %@", section)
            let titleSort = NSSortDescriptor(key: "position", ascending: true)
            request.sortDescriptors = [titleSort]
            return request
        }

        static func courseItems(forCourse course: Course) -> NSFetchRequest<CourseItem> {
            let request: NSFetchRequest<CourseItem> = CourseItem.fetchRequest()
            request.predicate = NSPredicate(format: "section.course = %@", course)
            let sectionSort = NSSortDescriptor(key: "section.position", ascending: true)
            let positionSort = NSSortDescriptor(key: "position", ascending: true)
            request.sortDescriptors = [sectionSort, positionSort]
            return request
        }

        static func courseItem(withId courseItemId: String) -> NSFetchRequest<CourseItem> {
            let request: NSFetchRequest<CourseItem> = CourseItem.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", courseItemId)
            request.fetchLimit = 1
            return request
        }

        static func courseItems(forCourse course: Course, withType type: String) -> NSFetchRequest<CourseItem> {
            let request: NSFetchRequest<CourseItem> = CourseItem.fetchRequest()
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                NSPredicate(format: "section.course = %@", course),
                NSPredicate(format: "icon = %@", type)
            ])
            return request
        }

    }

}
