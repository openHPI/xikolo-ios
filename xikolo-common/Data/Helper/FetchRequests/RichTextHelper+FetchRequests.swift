//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import CoreData

extension RichTextHelper {

    struct FetchRequest {

        static func richText(withId richTextId: String) -> NSFetchRequest<RichText> {
            let request: NSFetchRequest<RichText> = RichText.fetchRequest()
            request.predicate = NSPredicate(format: "id = %@", richTextId)
            request.fetchLimit = 1
            return request
        }

    }

}
