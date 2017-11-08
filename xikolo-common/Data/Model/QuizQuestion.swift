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

@objcMembers
final class QuizQuestion : NSManagedObject {

    @NSManaged var id: String
    @NSManaged var explanation: String?
    @NSManaged private var maxPointsValue: NSDecimalNumber?
    @NSManaged var shuffleOptions: Bool
    @NSManaged var text: String?
    @NSManaged var type: String?
    @NSManaged var position: Int32
    @NSManaged var options: [QuizOption]
    @NSManaged var quiz: Quiz?

    @objc dynamic var submission: QuizQuestionSubmission?

    var maxPoints: Double? {
        get {
            return self.maxPointsValue?.doubleValue
        }
        set {
            if let value = newValue {
                self.maxPointsValue = NSDecimalNumber(value: value)
            } else {
                self.maxPointsValue = nil
            }
        }
    }

//    var shuffle_answers: Bool {
//        get {
//            return shuffle_options_int?.boolValue ?? false
//        }
//        set(new_shuffle_answers) {
//            shuffle_options_int = new_shuffle_answers as NSNumber?
//        }
//    }

    var questionType: QuizQuestionType {
        guard let type = self.type else {
            return .unsupported
        }
        return QuizQuestionType.fromString(type)
    }

    var hasCorrectnessData: Bool {
        guard self.questionType != .unsupported else {
            return false
        }
        return self.options.filter({ $0.correct }).count > 0
    }

}

extension QuizQuestion : Pullable {

    static var type: String {
        return "quiz-questions"
    }

    func update(withObject object: ResourceData, including includes: [ResourceData]?, inContext context: NSManagedObjectContext) throws {
        let attributes = try object.value(for: "attributes") as JSON
        self.text = try attributes.value(for: "instructions")
        self.explanation = try attributes.value(for: "explanation")
        self.type = try attributes.value(for: "type")
        self.maxPoints = try attributes.value(for: "max_points")
        self.shuffleOptions = try attributes.value(for: "shuffle_options")
        self.position = try attributes.value(for: "position")
        self.options = try attributes.value(for: "options")
    }

}

//@objcMembers
//class QuizQuestionSpine : BaseModelSpine {
//
//    var text: String?
//    var explanation: String?
//    var type: String?
//    var max_points: NSDecimalNumber?
//    var shuffle_options_int: NSNumber?
//    var position: NSNumber?
//    var options: [QuizOption]?
//
//    override class var cdType: BaseModel.Type {
//        return QuizQuestion.self
//    }
//
//    override class var resourceType: ResourceType {
//        return "quiz-questions"
//    }
//
//    override class var fields: [Field] {
//        return fieldsFromDictionary([
//            "text": Attribute(),
//            "explanation": Attribute(),
//            "type": Attribute(),
//            "max_points": Attribute(),
//            "shuffle_options_int": BooleanAttribute().serializeAs("shuffle_options"),
//            "position": Attribute(),
//            "options": EmbeddedObjectsAttribute(QuizOption.self),
//        ])
//    }
//
//}

enum QuizQuestionType {

    case singleAnswer
    case multipleAnswer
    // case freeText
    case unsupported

    static func fromString(_ str: String) -> QuizQuestionType {
        switch str {
            case "select_one":
                return .singleAnswer
            case "select_multiple":
                return .multipleAnswer
            // case "free_text":
            //     return .freeText
            default:
                return .unsupported
        }
    }

}
