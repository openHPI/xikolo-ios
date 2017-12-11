//
//  QuizQuestion.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 28.07.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import CoreData
import Foundation

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
