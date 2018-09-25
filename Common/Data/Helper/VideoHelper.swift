//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures
import Foundation
import SyncEngine

struct VideoHelper {

    @discardableResult static func syncVideo(_ video: Video) -> Future<SyncSingleResult, XikoloError> {
        let fetchRequest = VideoHelper.FetchRequest.video(withId: video.id)
        let query = SingleResourceQuery(resource: video)

        let engine = XikoloSyncEngine()
        return engine.syncResource(withFetchRequest: fetchRequest, withQuery: query).mapError { error -> XikoloError in
            return .synchronization(error)
        }
    }

}
