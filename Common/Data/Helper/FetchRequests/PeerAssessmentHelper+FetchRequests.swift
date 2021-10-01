//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import CoreData

extension PeerAssessmentHelper {

    enum FetchRequest {

        static func peerAssessment(withId assessmentId: String) -> NSFetchRequest<PeerAssessment> {
            let request: NSFetchRequest<PeerAssessment> = PeerAssessment.fetchRequest()
            request.predicate = NSPredicate(format: "id = %@", assessmentId)
            request.fetchLimit = 1
            return request
        }

    }

}
