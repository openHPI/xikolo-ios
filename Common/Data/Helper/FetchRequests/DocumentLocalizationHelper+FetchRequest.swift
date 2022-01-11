//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import CoreData

public enum DocumentLocalizationHelper {

    public enum FetchRequest {

        public static func publicDocumentLocalizations(forCourse course: Course) -> NSFetchRequest<DocumentLocalization> {
            let request: NSFetchRequest<DocumentLocalization> = DocumentLocalization.fetchRequest()
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                NSPredicate(format: "%@ in document.courses", course),
                NSPredicate(format: "document.isPublic = %@", NSNumber(value: true)),
            ])
            let documentSortDescriptor = NSSortDescriptor(keyPath: \DocumentLocalization.document.title, ascending: true)
            let localizationSortDescriptor = NSSortDescriptor(keyPath: \DocumentLocalization.title, ascending: true)
            request.sortDescriptors = [documentSortDescriptor, localizationSortDescriptor]
            return request
        }

        public static func downloadedDocumentLocalizations(forCourse course: Course) -> NSFetchRequest<DocumentLocalization> {
            let request = publicDocumentLocalizations(forCourse: course)
            let predicates = request.predicate.require(hint: "Self declared request is missing predicate")
            let downloadedPredicate = NSPredicate(format: "localFileBookmark != nil")
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicates, downloadedPredicate])
            return request
        }

        public static func hasDownloadedLocalization() -> NSFetchRequest<DocumentLocalization> {
            let request: NSFetchRequest<DocumentLocalization> = DocumentLocalization.fetchRequest()
            request.predicate = NSPredicate(format: "localFileBookmark != nil")
            return request
        }

    }

}
