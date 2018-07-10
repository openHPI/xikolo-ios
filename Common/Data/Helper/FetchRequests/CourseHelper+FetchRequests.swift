//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import CoreData

extension CourseHelper {

    public struct FetchRequest {

        private static let genericPredicate = NSPredicate(format: "external != %@", NSNumber(value: true))

        private static let deletedEnrollmentPrecidate = NSPredicate(format: "enrollment.objectStateValue = %d", ObjectState.deleted.rawValue)
        private static let notDeletedEnrollmentPredicate = NSCompoundPredicate(notPredicateWithSubpredicate: deletedEnrollmentPrecidate)

        private static let enrolledPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "enrollment != nil"),
            notDeletedEnrollmentPredicate,
        ])
        private static let notEnrolledPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [
            NSPredicate(format: "enrollment = nil"),
            deletedEnrollmentPrecidate,
        ])

        private static let announcedPredicate = NSPredicate(format: "status = %@", "announced")
        private static let previewPredicate = NSPredicate(format: "status = %@", "preview")
        private static let activePredicate = NSPredicate(format: "status = %@", "active")
        private static let selfpacedPredicate = NSPredicate(format: "status = %@", "self-paced")
        private static let accessiblePredicate = NSPredicate(format: "accessible = %@", NSNumber(value: true))
        private static let interestingPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [
            announcedPredicate,
            previewPredicate,
            activePredicate,
        ])

        private static let completedPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            enrolledPredicate,
            NSPredicate(format: "enrollment.completed = %@", NSNumber(value: true)),
        ])
        private static let notCompletedPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [
            NSCompoundPredicate(andPredicateWithSubpredicates: [
                enrolledPredicate,
                NSPredicate(format: "enrollment.completed = %@", NSNumber(value: false)),
            ]),
            notEnrolledPredicate,
        ])

        private static var genericCoursesRequest: NSFetchRequest<Course> {
            let request: NSFetchRequest<Course> = Course.fetchRequest()
            let customOrderSort = NSSortDescriptor(key: "order", ascending: true)
            request.sortDescriptors = [customOrderSort]
            request.predicate = self.genericPredicate
            return request
        }

        static func course(withId courseId: String) -> NSFetchRequest<Course> {
            let request: NSFetchRequest<Course> = Course.fetchRequest()
            request.predicate = NSPredicate(format: "id = %@", courseId)
            request.fetchLimit = 1
            return request
        }

        public static func course(withSlugOrId slugOrId: String) -> NSFetchRequest<Course> {
            let request: NSFetchRequest<Course> = Course.fetchRequest()
            request.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [
                NSPredicate(format: "slug = %@", slugOrId),
                NSPredicate(format: "id = %@", slugOrId),
            ])
            request.fetchLimit = 1
            return request
        }

        static var allCourses: NSFetchRequest<Course> {
            return Course.fetchRequest() as NSFetchRequest<Course>
        }

        public static var accessibleCourses: NSFetchRequest<Course> {
            let request = self.genericCoursesRequest
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                genericPredicate,
                accessiblePredicate,
            ])
            return request
        }

        static var interestingCoursesRequest: NSFetchRequest<Course> {
            let request = self.genericCoursesRequest
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                genericPredicate,
                notEnrolledPredicate,
                interestingPredicate,
            ])
            return request
        }

        public static var currentCourses: NSFetchRequest<Course> {
            let request = self.genericCoursesRequest
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                genericPredicate,
                accessiblePredicate,
                notCompletedPredicate,
                activePredicate,
            ])
            return request
        }

        public static var upcomingCourses: NSFetchRequest<Course> {
            let request = self.genericCoursesRequest
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                genericPredicate,
                announcedPredicate,
                notCompletedPredicate,
            ])
            return request
        }

        public static var selfpacedCourses: NSFetchRequest<Course> {
            let request = self.genericCoursesRequest
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                genericPredicate,
                selfpacedPredicate,
            ])
            return request
        }

        static var pastCourses: NSFetchRequest<Course> {
            let request = self.genericCoursesRequest
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                genericPredicate,
                notEnrolledPredicate,
                selfpacedPredicate,
            ])
            return request
        }

        public static var enrolledCourses: NSFetchRequest<Course> {
            let request = self.genericCoursesRequest
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                genericPredicate,
                enrolledPredicate,
                accessiblePredicate,
            ])
            return request
        }

        static var enrolledCurrentCoursesRequest: NSFetchRequest<Course> {
            let request = self.genericCoursesRequest
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                genericPredicate,
                enrolledPredicate,
                accessiblePredicate,
                notCompletedPredicate,
                activePredicate,
            ])
            return request
        }

        static var enrolledSelfPacedCourses: NSFetchRequest<Course> {
            let request = self.genericCoursesRequest
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                genericPredicate,
                enrolledPredicate,
                accessiblePredicate,
                notCompletedPredicate,
                selfpacedPredicate,
            ])
            return request
        }

        static var enrolledUpcomingCourses: NSFetchRequest<Course> {
            let request = self.genericCoursesRequest
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                genericPredicate,
                enrolledPredicate,
                announcedPredicate,
                notCompletedPredicate,
            ])
            return request
        }

        static var enrolledNotCompletedCourses: NSFetchRequest<Course> {
            let request = self.genericCoursesRequest
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                genericPredicate,
                enrolledPredicate,
                notCompletedPredicate,
            ])
            return request
        }

        static var completedCourses: NSFetchRequest<Course> {
            let request = self.genericCoursesRequest
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                genericPredicate,
                enrolledPredicate,
                completedPredicate,
            ])
            return request
        }

        static var allCoursesSectioned: NSFetchRequest<Course> {
            let request = self.genericCoursesRequest
            let enrolledSort = NSSortDescriptor(key: "enrollment", ascending: false)
            let startDateSort = NSSortDescriptor(key: "startsAt", ascending: false)
            request.sortDescriptors = [enrolledSort, startDateSort]
            return request
        }

    }

}
