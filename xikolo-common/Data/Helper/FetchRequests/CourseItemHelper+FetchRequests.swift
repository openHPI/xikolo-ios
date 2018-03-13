//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import CoreData

extension CourseItemHelper {

    struct FetchRequest {

        static func orderedCourseItems(forSection section: CourseSection) -> NSFetchRequest<CourseItem> {
            let request: NSFetchRequest<CourseItem> = CourseItem.fetchRequest()
            request.predicate = NSPredicate(format: "section = %@", section)
            let titleSort = NSSortDescriptor(key: "position", ascending: true)
            request.sortDescriptors = [titleSort]
            return request
        }

        static func orderedCourseItems(forCourse course: Course) -> NSFetchRequest<CourseItem> {
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
                NSPredicate(format: "icon = %@", type),
            ])
            return request
        }

    }

}
