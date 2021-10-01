//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import CoreData

extension EnrollmentHelper {

    public enum FetchRequest {

        public static func allEnrollments() -> NSFetchRequest<Enrollment> {
            let request: NSFetchRequest<Enrollment> = Enrollment.fetchRequest()
            let courseDateSort = NSSortDescriptor(keyPath: \Enrollment.course?.startsAt, ascending: false)
            let courseTitleSort = NSSortDescriptor(keyPath: \Enrollment.course?.title, ascending: true)
            request.sortDescriptors = [courseDateSort, courseTitleSort]
            return request
        }

    }

}
