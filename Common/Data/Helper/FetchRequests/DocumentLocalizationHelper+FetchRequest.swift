//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import CoreData

public struct DocumentLocalizationHelper {

    public struct FetchRequest {

        public static func publicDocumentLocalizations(forCourse course: Course) -> NSFetchRequest<DocumentLocalization> {
            let request: NSFetchRequest<DocumentLocalization> = DocumentLocalization.fetchRequest()
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                NSPredicate(format: "%@ in document.courses", course),
                NSPredicate(format: "document.isPublic = %@", NSNumber(value: true)),
            ])
            let documentSortDescriptor = NSSortDescriptor(key: "document.title", ascending: true)
            let localizationSortDescriptor = NSSortDescriptor(key: "title", ascending: true)
            request.sortDescriptors = [documentSortDescriptor, localizationSortDescriptor]
            return request
        }

    }

}
