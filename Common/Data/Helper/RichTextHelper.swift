//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures
import Foundation
import Stockpile

enum RichTextHelper {

    @discardableResult static func syncRichText(_ richText: RichText) -> Future<SyncSingleResult, XikoloError> {
        let fetchRequest = Self.FetchRequest.richText(withId: richText.id)
        let query = SingleResourceQuery(resource: richText)
        return XikoloSyncEngine().synchronize(withFetchRequest: fetchRequest, withQuery: query)
    }

}
