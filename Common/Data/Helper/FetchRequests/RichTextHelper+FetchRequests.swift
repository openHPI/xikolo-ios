//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import CoreData

extension RichTextHelper {

    enum FetchRequest {

        static func richText(withId richTextId: String) -> NSFetchRequest<RichText> {
            let request: NSFetchRequest<RichText> = RichText.fetchRequest()
            request.predicate = NSPredicate(format: "id = %@", richTextId)
            request.fetchLimit = 1
            return request
        }

    }

}
