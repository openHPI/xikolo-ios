//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import CoreData
import Stockpile

extension CourseDateHelper {

    public enum FetchRequest {

        private static var enrolledCoursePredicate: NSPredicate {
            let deletedEnrollmentPrecidate = NSPredicate(format: "course.enrollment.objectStateValue = %d", ObjectState.deleted.rawValue)
            let notDeletedEnrollmentPredicate = NSCompoundPredicate(notPredicateWithSubpredicate: deletedEnrollmentPrecidate)
            return NSCompoundPredicate(andPredicateWithSubpredicates: [
                NSPredicate(format: "course.enrollment != nil"),
                notDeletedEnrollmentPredicate,
            ])
        }

        public static var allCourseDates: NSFetchRequest<CourseDate> {
            let request: NSFetchRequest<CourseDate> = CourseDate.fetchRequest()
            let dateSort = NSSortDescriptor(keyPath: \CourseDate.date, ascending: true)
            let courseSort = NSSortDescriptor(keyPath: \CourseDate.course?.title, ascending: true)
            let titleSort = NSSortDescriptor(keyPath: \CourseDate.title, ascending: true)
            request.sortDescriptors = [dateSort, courseSort, titleSort]
            request.predicate = self.enrolledCoursePredicate
            return request
        }

        public static func courseDates(for course: Course) -> NSFetchRequest<CourseDate> {
            let request: NSFetchRequest<CourseDate> = CourseDate.fetchRequest()
            let dateSort = NSSortDescriptor(keyPath: \CourseDate.date, ascending: true)
            request.sortDescriptors = [dateSort]
            request.predicate = NSPredicate(format: "course = %@", course)
            return request
        }

        public static var nextCourseDate: NSFetchRequest<CourseDate> {
            let request: NSFetchRequest<CourseDate> = CourseDate.fetchRequest()
            let dateSort = NSSortDescriptor(keyPath: \CourseDate.date, ascending: true)
            request.sortDescriptors = [dateSort]
            request.predicate = self.enrolledCoursePredicate
            request.fetchLimit = 1
            return request
        }

        public static func courseDatesForNextDays(numberOfDays: Int) -> NSFetchRequest<CourseDate> {
            var calendar = Calendar.current
            calendar.timeZone = TimeZone.current

            let today = Date()
            let fromDate = calendar.startOfDay(for: today)
            let toDate = calendar.date(byAdding: .day, value: numberOfDays, to: fromDate).require()

            let fromPredicate = NSPredicate(format: "date >= %@", today as NSDate)
            let toPredicate = NSPredicate(format: "date < %@", toDate as NSDate)

            let request: NSFetchRequest<CourseDate> = CourseDate.fetchRequest()
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [fromPredicate, toPredicate, self.enrolledCoursePredicate])
            return request
        }

    }

}
