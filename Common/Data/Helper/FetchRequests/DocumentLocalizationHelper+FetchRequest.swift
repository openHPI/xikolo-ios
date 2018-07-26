//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import CoreData

public struct DocumentLocalizationHelper {

    public struct FetchRequest {

        public static func documentLocalizations(forCourse course: Course) -> NSFetchRequest<DocumentLocalization> {
            let request: NSFetchRequest<DocumentLocalization> = DocumentLocalization.fetchRequest()
            request.predicate = NSPredicate(format: "%@ in document.courses", course)
            let documentSortDescriptor = NSSortDescriptor(key: "document.title", ascending: true)
            let localizationSortDescriptor = NSSortDescriptor(key: "title", ascending: true)
            request.sortDescriptors = [documentSortDescriptor, localizationSortDescriptor]
            return request
        }

    }

}
