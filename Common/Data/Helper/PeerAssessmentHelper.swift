//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures
import Foundation

struct PeerAssessmentHelper {

    @discardableResult static func syncPeerAssessment(_ peerAssessment: PeerAssessment) -> Future<SyncEngine.SyncSingleResult, XikoloError> {
        let fetchRequest = PeerAssessmentHelper.FetchRequest.peerAssessment(withId: peerAssessment.id)
        let query = SingleResourceQuery(resource: peerAssessment)
        return SyncEngine.shared.syncResource(withFetchRequest: fetchRequest, withQuery: query)
    }

}
