//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import CoreData
import SyncEngine

extension CourseHelper {

    public enum FetchRequest {

        private static let visiblePredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "external != %@", NSNumber(value: true)),
            NSPredicate(format: "status != %@", "preparation"),
        ])

        private static let deletedEnrollmentPredicate = NSPredicate(format: "enrollment.objectStateValue = %d", ObjectState.deleted.rawValue)
        private static let notDeletedEnrollmentPredicate = NSCompoundPredicate(notPredicateWithSubpredicate: deletedEnrollmentPredicate)

        private static let enrolledPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "enrollment != nil"),
            notDeletedEnrollmentPredicate,
        ])
        private static let notEnrolledPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [
            NSPredicate(format: "enrollment = nil"),
            deletedEnrollmentPredicate,
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

        private static let futurePredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [
            NSPredicate(format: "startsAt = nil"),
            NSPredicate(format: "startsAt > now()"),
        ])
        private static let pastPredicate: NSPredicate = {
            if Brand.default.showCurrentCoursesInSelfPacedSection {
                return NSCompoundPredicate(notPredicateWithSubpredicate: futurePredicate)
            } else {
                return NSCompoundPredicate(andPredicateWithSubpredicates: [
                    NSPredicate(format: "endsAt != nil"),
                    NSPredicate(format: "endsAt < now()"),
                ])
            }
        }()

        private static let currentCoursesPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            visiblePredicate,
            NSCompoundPredicate(notPredicateWithSubpredicate: futurePredicate),
            NSCompoundPredicate(notPredicateWithSubpredicate: pastPredicate),
        ])
        private static let upcomingCoursesPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            visiblePredicate,
            futurePredicate,
        ])
        private static let selfpacedCoursesPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
            visiblePredicate,
            pastPredicate,
        ])

        private static let customOrderSortDescriptor = NSSortDescriptor(keyPath: \Course.order, ascending: true)

        private static var visibleCoursesRequest: NSFetchRequest<Course> {
            let request: NSFetchRequest<Course> = Course.fetchRequest()
            request.sortDescriptors = [self.customOrderSortDescriptor]
            request.predicate = self.visiblePredicate
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

        public static var currentCourses: NSFetchRequest<Course> {
            let request = self.visibleCoursesRequest
            request.predicate = self.currentCoursesPredicate
            request.sortDescriptors = [
                NSSortDescriptor(keyPath: \Course.startsAt, ascending: true),
                NSSortDescriptor(keyPath: \Course.title, ascending: true),
            ]
            return request
        }

        public static var upcomingCourses: NSFetchRequest<Course> {
            let request = self.visibleCoursesRequest
            request.predicate = self.upcomingCoursesPredicate
            request.sortDescriptors = [
                NSSortDescriptor(keyPath: \Course.startsAt, ascending: true),
                NSSortDescriptor(keyPath: \Course.title, ascending: true),
            ]
            return request
        }

        public static var selfpacedCourses: NSFetchRequest<Course> {
            let request = self.visibleCoursesRequest
            request.predicate = self.selfpacedCoursesPredicate
            return request
        }

        public static var searchableCourses: NSFetchRequest<Course> {
            let request = self.visibleCoursesRequest
            request.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [
                self.currentCoursesPredicate,
                self.upcomingCoursesPredicate,
                self.selfpacedCoursesPredicate,
            ])
            return request
        }

        public static var enrolledCurrentCoursesRequest: NSFetchRequest<Course> {
            let request = self.visibleCoursesRequest
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                visiblePredicate,
                enrolledPredicate,
                notCompletedPredicate,
            ])
            request.sortDescriptors = [
                NSSortDescriptor(keyPath: \Course.lastVisited, ascending: false),
                self.customOrderSortDescriptor,
            ]
            return request
        }

        public static var completedCourses: NSFetchRequest<Course> {
            let request = self.visibleCoursesRequest
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                visiblePredicate,
                enrolledPredicate,
                completedPredicate,
            ])
            return request
        }

    }

}
