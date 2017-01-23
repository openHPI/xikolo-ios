//
//  LTIExercise.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 20.08.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import CoreData
import Foundation
import Spine

class LTIExercise : Content {

    override func iconName() -> String {
        return "lti_exercise"
    }

}

class LTIExerciseSpine : ContentSpine {

    var instructions: String?
    var weight: NSNumber?
    var allowed_attempts: NSNumber?
    var lock_submissions_at: Date?

    override class var cdType: BaseModel.Type {
        return LTIExercise.self
    }

    override class var resourceType: ResourceType {
        return "lti-exercises"
    }

    override class var fields: [Field] {
        return fieldsFromDictionary([
            "instructions": Attribute(),
            "weight": Attribute(),
            "allowed_attempts": Attribute(),
            "lock_submissions_at": DateAttribute(),
        ])
    }
    
}
