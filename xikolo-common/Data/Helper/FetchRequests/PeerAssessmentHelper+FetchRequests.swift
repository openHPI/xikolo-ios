//
//  PeerAssessmentHelper+FetchRequests.swift
//  xikolo-ios
//
//  Created by Max Bothe on 16.11.17.
//  Copyright © 2017 HPI. All rights reserved.
//

import CoreData

extension PeerAssessmentHelper {

    struct FetchRequest {

        static func peerAssessment(withId assessmentId: String) -> NSFetchRequest<PeerAssessment> {
            let request: NSFetchRequest<PeerAssessment> = PeerAssessment.fetchRequest()
            request.predicate = NSPredicate(format: "id = %@", assessmentId)
            request.fetchLimit = 1
            return request
        }

    }

}
