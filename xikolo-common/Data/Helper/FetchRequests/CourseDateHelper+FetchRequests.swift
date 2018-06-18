//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import CoreData

extension CourseDateHelper {

    struct FetchRequest {

        static var allCourseDates: NSFetchRequest<CourseDate> {
            let request: NSFetchRequest<CourseDate> = CourseDate.fetchRequest()
            let dateSort = NSSortDescriptor(key: "date", ascending: true)
            let courseSort = NSSortDescriptor(key: "course.title", ascending: true)
            let titleSort = NSSortDescriptor(key: "title", ascending: true)
            request.sortDescriptors = [dateSort, courseSort, titleSort]
            return request
        }

        static func courseDates(for course: Course) -> NSFetchRequest<CourseDate> {
            let request: NSFetchRequest<CourseDate> = CourseDateHelper.FetchRequest.allCourseDates
            request.predicate = NSPredicate(format: "course = %@", course)
            return request
        }

    }

}
