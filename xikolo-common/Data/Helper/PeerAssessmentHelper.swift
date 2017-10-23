//
//  PeerAssessmentHelper.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 18.09.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import BrightFutures
import Foundation

class PeerAssessmentHelper {

    static func refreshPeerAssessment(_ peerAssessment: PeerAssessment) -> Future<PeerAssessment, XikoloError> {
        return PeerAssessmentProvider.getPeerAssessment(peerAssessment.id).flatMap { spinePeerAssessment -> Future<[PeerAssessment], XikoloError> in
            return SpineModelHelper.syncObjectsFuture([peerAssessment], spineObjects: [spinePeerAssessment], inject: nil, save: true)
        }.map { cdPeerAssessments in
            return cdPeerAssessments[0]
        }
    }
    
}
