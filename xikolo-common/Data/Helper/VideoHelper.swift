//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation
import CoreData
import BrightFutures

struct VideoHelper {

    @discardableResult static func syncVideo(_ video: Video) -> Future<SyncEngine.SyncSingleResult, XikoloError> {
        let fetchRequest = VideoHelper.FetchRequest.video(withId: video.id)
        let query = SingleResourceQuery(resource: video)
        return SyncHelper.syncResource(withFetchRequest: fetchRequest, withQuery: query)
    }

}
