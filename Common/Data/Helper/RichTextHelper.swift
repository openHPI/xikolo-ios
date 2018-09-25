//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures
import Foundation
import SyncEngine

struct RichTextHelper {

    @discardableResult static func syncRichText(_ richText: RichText) -> Future<SyncEngine.SyncSingleResult, XikoloError> {
        let fetchRequest = RichTextHelper.FetchRequest.richText(withId: richText.id)
        let query = SingleResourceQuery(resource: richText)
        return SyncEngine.syncResourceXikolo(withFetchRequest: fetchRequest, withQuery: query)
    }

}
