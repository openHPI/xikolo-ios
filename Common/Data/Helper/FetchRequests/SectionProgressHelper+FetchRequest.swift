//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import CoreData

public enum SectionProgressHelper {

    public enum FetchRequest {

        public static func sectionProgresses(forCourse course: Course) -> NSFetchRequest<SectionProgress> {
            let request: NSFetchRequest<SectionProgress> = SectionProgress.fetchRequest()
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                NSPredicate(format: "courseProgress.id = %@", course.id),
                NSPredicate(format: "available = %@", NSNumber(value: true)),
            ])
            let positionSort = NSSortDescriptor(keyPath: \SectionProgress.position, ascending: true)
            request.sortDescriptors = [positionSort]
            return request
        }

    }

}
