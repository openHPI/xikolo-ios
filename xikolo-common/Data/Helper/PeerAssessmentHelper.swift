//
//  PeerAssessmentHelper.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 18.09.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import BrightFutures
import Foundation
import Result

class PeerAssessmentHelper {

    static func refreshPeerAssessment(peerAssessment: PeerAssessment) -> Future<PeerAssessment, XikoloError> {
        return PeerAssessmentProvider.getPeerAssessment(peerAssessment.id).flatMap { spinePeerAssessment -> Future<[BaseModel], XikoloError> in
            return SpineModelHelper.syncObjectsFuture([peerAssessment], spineObjects: [spinePeerAssessment], inject: nil, save: true)
        }.map { cdPeerAssessments in
            return cdPeerAssessments[0] as! PeerAssessment
        }
    }
    
}
