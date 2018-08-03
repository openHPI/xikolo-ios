//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import CoreData

extension CourseDateHelper {

    public struct FetchRequest {

        public static var allCourseDates: NSFetchRequest<CourseDate> {
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

        public static var nextCourseDate: NSFetchRequest<CourseDate> {
            let request: NSFetchRequest<CourseDate> = CourseDate.fetchRequest()
            let dateSort = NSSortDescriptor(key: "date", ascending: true)
            request.sortDescriptors = [dateSort]
            request.fetchLimit = 1
            return request
        }

        public static func courseDatesForNextDays(numberOfDays: Int) -> NSFetchRequest<CourseDate> {
            var calendar = Calendar.current
            calendar.timeZone = TimeZone.current

            let today = Date()
            let fromDate = calendar.startOfDay(for: today)
            let toDate = calendar.date(byAdding: .day, value: numberOfDays, to: fromDate).require()

            let fromPredicate = NSPredicate(format: "date >= %@", fromDate as NSDate)
            let toPredicate = NSPredicate(format: "date < %@", toDate as NSDate)

            let request: NSFetchRequest<CourseDate> = CourseDate.fetchRequest()
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [fromPredicate, toPredicate])
            return request
        }

    }

}
