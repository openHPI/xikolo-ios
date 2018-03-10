//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation
import CoreData
import BrightFutures

struct RichTextHelper {

    @discardableResult static func syncRichText(_ richText: RichText) -> Future<SyncEngine.SyncSingleResult, XikoloError> {
        let fetchRequest = RichTextHelper.FetchRequest.richText(withId: richText.id)
        let query = SingleResourceQuery(resource: richText)
        return SyncHelper.syncResource(withFetchRequest: fetchRequest, withQuery: query)
    }

}
