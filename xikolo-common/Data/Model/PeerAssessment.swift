//
//  PeerAssessment.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 20.08.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import CoreData
import Foundation
import Spine

class PeerAssessment : Content {

    override func iconName() -> String {
        return "peer_assessment"
    }

}

class PeerAssessmentSpine : ContentSpine {

    var title: String?

    override class var cdType: BaseModel.Type {
        return PeerAssessment.self
    }

    override class var resourceType: ResourceType {
        return "peer-assessments"
    }

    override class var fields: [Field] {
        return fieldsFromDictionary([
            "title": Attribute()
        ])
    }
    
}
