//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import CoreData

public enum SectionProgressHelper {

    public enum FetchRequest {

        public static func sectionProgresses(forCourse course: Course) -> NSFetchRequest<SectionProgress> {
            let request: NSFetchRequest<SectionProgress> = SectionProgress.fetchRequest()
            request.predicate = NSPredicate(format: "courseProgress.id = %@", course.id)
            let positionSort = NSSortDescriptor(keyPath: \SectionProgress.position, ascending: true)
            request.sortDescriptors = [positionSort]
            return request
        }

    }

}
