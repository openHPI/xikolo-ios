//
//  QuizQuestion.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 28.07.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import CoreData
import Foundation
import Spine

class QuizQuestion : BaseModel {

    var shuffle_answers: Bool {
        get {
            return shuffle_answers_int?.boolValue ?? false
        }
        set(new_shuffle_answers) {
            shuffle_answers_int = new_shuffle_answers
        }
    }

}

class QuizQuestionSpine : BaseModelSpine {

    var text: String?
    var explanation: String?
    var type: String?
    var max_points: NSDecimalNumber?
    var shuffle_answers_int: NSNumber?

    override class var cdType: BaseModel.Type {
        return QuizQuestion.self
    }

    override class var resourceType: ResourceType {
        return "quiz-questions"
    }

    override class var fields: [Field] {
        return fieldsFromDictionary([
            "text": Attribute(),
            "explanation": Attribute(),
            "type": Attribute(),
            "max_points": Attribute(),
            "shuffle_answers_int": Attribute().serializeAs("shuffle_answers"),
        ])
    }

}
