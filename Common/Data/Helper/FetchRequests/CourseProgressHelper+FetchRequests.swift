//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import CoreData

extension CourseProgressHelper {

    public enum FetchRequest {

        static func courseProgress(forCourse course: Course) -> NSFetchRequest<CourseProgress> {
            let request: NSFetchRequest<CourseProgress> = CourseProgress.fetchRequest()
            request.predicate = NSPredicate(format: "id = %@", course.id)
            request.fetchLimit = 1
            return request
        }

    }

}
