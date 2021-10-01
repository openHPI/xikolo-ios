//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import CoreData

public extension CourseProgressHelper {

    enum FetchRequest {

        public static func courseProgress(forCourse course: Course) -> NSFetchRequest<CourseProgress> {
            let request: NSFetchRequest<CourseProgress> = CourseProgress.fetchRequest()
            request.predicate = NSPredicate(format: "id = %@", course.id)
            request.fetchLimit = 1
            return request
        }

    }

}
