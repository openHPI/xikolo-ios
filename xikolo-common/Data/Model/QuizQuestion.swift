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

    dynamic var submission: QuizQuestionSubmission?

    var shuffle_answers: Bool {
        get {
            return shuffle_answers_int?.boolValue ?? false
        }
        set(new_shuffle_answers) {
            shuffle_answers_int = new_shuffle_answers
        }
    }

    var questionType: QuizQuestionType {
        if type == nil {
            return .Unsupported
        }
        return QuizQuestionType.fromString(type!)
    }

    var hasCorrectnessData: Bool {
        guard let answers = answers else {
            return false
        }
        return answers.filter({ $0.correct ?? false }).count > 0
    }

}

class QuizQuestionSpine : BaseModelSpine {

    var text: String?
    var explanation: String?
    var type: String?
    var max_points: NSDecimalNumber?
    var shuffle_answers_int: NSNumber?
    var answers: [QuizAnswer]?

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
            "answers": EmbeddedObjectsAttribute(QuizAnswer),
        ])
    }

}

enum QuizQuestionType {

    case SingleAnswer
    case MultipleAnswer
    case FreeText
    case Unsupported

    static func fromString(str: String) -> QuizQuestionType {
        switch str {
            case "single_answer":
                return .SingleAnswer
            case "multiple_answer":
                return .MultipleAnswer
            case "free_text":
                return .FreeText
            default:
                return .Unsupported
        }
    }

}
