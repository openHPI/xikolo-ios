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
            return shuffle_options_int?.boolValue ?? false
        }
        set(new_shuffle_answers) {
            shuffle_options_int = new_shuffle_answers
        }
    }

    var questionType: QuizQuestionType {
        if type == nil {
            return .Unsupported
        }
        return QuizQuestionType.fromString(type!)
    }

    var hasCorrectnessData: Bool {
        guard let options = options else {
            return false
        }
        return options.filter({ $0.correct ?? false }).count > 0
    }

}

class QuizQuestionSpine : BaseModelSpine {

    var text: String?
    var explanation: String?
    var type: String?
    var max_points: NSDecimalNumber?
    var shuffle_options_int: NSNumber?
    var options: [QuizOption]?

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
            "shuffle_options_int": Attribute().serializeAs("shuffle_options"),
            "options": EmbeddedObjectsAttribute(QuizOption),
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
            case "select_one":
                return .SingleAnswer
            case "select_multiple":
                return .MultipleAnswer
            case "free_text":
                return .FreeText
            default:
                return .Unsupported
        }
    }

}
