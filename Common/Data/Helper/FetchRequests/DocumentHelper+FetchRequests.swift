//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import CoreData

extension DocumentHelper {

    public struct FetchRequest {

        public static func documents(forCourse course: Course) -> NSFetchRequest<Document> {
            let request: NSFetchRequest<Document> = Document.fetchRequest()
            request.predicate = NSPredicate(format: "%@ in courses", course)
            return request
        }

        public static func hasDownloadedLocalization() -> NSFetchRequest<Document> {
            let request: NSFetchRequest<Document> = Document.fetchRequest()
            request.predicate = NSPredicate(format: "ANY localizations.localFileBookmark != nil")
            return request
        }

    }

}
