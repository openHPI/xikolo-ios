//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import CoreData

extension CourseItemHelper {

    public enum FetchRequest {

        static func courseItems(forCourse course: Course) -> NSFetchRequest<CourseItem> {
            let request: NSFetchRequest<CourseItem> = CourseItem.fetchRequest()
            request.predicate = NSPredicate(format: "section.course = %@", course)
            return request
        }

        public static func orderedCourseItems(forCourse course: Course) -> NSFetchRequest<CourseItem> {
            let request = self.courseItems(forCourse: course)
            let sectionSort = NSSortDescriptor(keyPath: \CourseItem.section?.position, ascending: true)
            let positionSort = NSSortDescriptor(keyPath: \CourseItem.position, ascending: true)
            request.sortDescriptors = [sectionSort, positionSort]
            return request
        }

        static func orderedCourseItems(forSection section: CourseSection) -> NSFetchRequest<CourseItem> {
            let request: NSFetchRequest<CourseItem> = CourseItem.fetchRequest()
            request.predicate = NSPredicate(format: "section = %@", section)
            let titleSort = NSSortDescriptor(keyPath: \CourseItem.position, ascending: true)
            request.sortDescriptors = [titleSort]
            return request
        }

        public static func courseItem(withId courseItemId: String) -> NSFetchRequest<CourseItem> {
            let request: NSFetchRequest<CourseItem> = CourseItem.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", courseItemId)
            request.fetchLimit = 1
            return request
        }

        static func courseItems(forCourse course: Course, withContentType type: String) -> NSFetchRequest<CourseItem> {
            let request: NSFetchRequest<CourseItem> = CourseItem.fetchRequest()
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                NSPredicate(format: "section.course = %@", course),
                NSPredicate(format: "contentType = %@", type),
            ])
            return request
        }

        static func courseItems(forSection section: CourseSection, withContentType type: String) -> NSFetchRequest<CourseItem> {
            let request: NSFetchRequest<CourseItem> = CourseItem.fetchRequest()
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                NSPredicate(format: "section = %@", section),
                NSPredicate(format: "contentType = %@", type),
            ])
            return request
        }

    }

}
