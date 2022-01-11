//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import CoreData

extension DocumentHelper {

    public enum FetchRequest {

        public static func documents(forCourse course: Course) -> NSFetchRequest<Document> {
            let request: NSFetchRequest<Document> = Document.fetchRequest()
            request.predicate = NSPredicate(format: "%@ in courses", course)
            return request
        }

    }

}
