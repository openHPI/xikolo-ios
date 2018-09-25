//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures
import Foundation
import SyncEngine

struct PeerAssessmentHelper {

    @discardableResult static func syncPeerAssessment(_ peerAssessment: PeerAssessment) -> Future<SyncSingleResult, XikoloError> {
        let fetchRequest = PeerAssessmentHelper.FetchRequest.peerAssessment(withId: peerAssessment.id)
        let query = SingleResourceQuery(resource: peerAssessment)

        let config = XikoloSyncConfig()
        let strategy = JsonAPISyncStrategy()
        let engine = SyncEngine(configuration: config, strategy: strategy)
        return engine.syncResource(withFetchRequest: fetchRequest, withQuery: query).mapError { error -> XikoloError in
            return .synchronization(error)
        }
    }

}
