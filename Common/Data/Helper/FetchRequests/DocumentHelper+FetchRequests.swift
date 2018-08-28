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

        public static func downloaded() -> NSFetchRequest<Document> {
            let request: NSFetchRequest<Document> = Document.fetchRequest()
            request.predicate = NSPredicate(format: "ANY localization.localFileURL != nil")
            return request
        }

        public static func downloadedSorted() -> NSFetchRequest<Document> {
            let request: NSFetchRequest<Document> = Document.fetchRequest()
            request.predicate = NSPredicate(format: "ANY localization.localFileURL != nil")
            let titleSort = NSSortDescriptor(key: "title", ascending: true)
            //let positionSort = NSSortDescriptor(key: "item.position", ascending: true)
            request.sortDescriptors = [titleSort]
            return request
        }

    }

}
