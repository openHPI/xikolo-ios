//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import CoreData
import Stockpile

extension AnnouncementHelper {

    public enum FetchRequest {

        private static var enrolledCoursePredicate: NSPredicate {
            let deletedEnrollmentPredicate = NSPredicate(format: "course.enrollment.objectStateValue = %d", ObjectState.deleted.rawValue)
            let notDeletedEnrollmentPredicate = NSCompoundPredicate(notPredicateWithSubpredicate: deletedEnrollmentPredicate)
            return NSCompoundPredicate(andPredicateWithSubpredicates: [
                NSPredicate(format: "course.enrollment != nil"),
                notDeletedEnrollmentPredicate,
            ])
        }

        private static var noCourseOrEnrolledCoursePredicate: NSPredicate {
            return NSCompoundPredicate(orPredicateWithSubpredicates: [
                NSPredicate(format: "course == nil"),
                self.enrolledCoursePredicate,
            ])
        }

        public static var allAnnouncements: NSFetchRequest<Announcement> {
            let request: NSFetchRequest<Announcement> = Announcement.fetchRequest()
            let dateSort = NSSortDescriptor(keyPath: \Announcement.publishedAt, ascending: false)
            request.sortDescriptors = [dateSort]
            request.predicate = self.noCourseOrEnrolledCoursePredicate
            return request
        }

        public static var unreadAnnouncements: NSFetchRequest<Announcement> {
            let request: NSFetchRequest<Announcement> = Announcement.fetchRequest()
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                NSPredicate(format: "visited = %@", NSNumber(value: false)),
                self.noCourseOrEnrolledCoursePredicate,
            ])
            return request
        }

        public static func announcements(forCourse course: Course) -> NSFetchRequest<Announcement> {
            let request: NSFetchRequest<Announcement> = Announcement.fetchRequest()
            let dateSort = NSSortDescriptor(keyPath: \Announcement.publishedAt, ascending: false)
            request.sortDescriptors = [dateSort]
            request.predicate = NSPredicate(format: "course = %@", course)
            return request
        }

    }

}
