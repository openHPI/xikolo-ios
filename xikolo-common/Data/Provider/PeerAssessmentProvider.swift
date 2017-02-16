//
//  PeerAssessmentProvider.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 13.09.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import BrightFutures
import Foundation

class PeerAssessmentProvider {

    class func getPeerAssessment(_ peerAssessmentId: String) -> Future<PeerAssessmentSpine, XikoloError> {
        return SpineHelper.findOne(peerAssessmentId, ofType: PeerAssessmentSpine.self)
    }
    
}
