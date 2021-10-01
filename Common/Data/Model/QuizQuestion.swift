//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import CoreData
import Foundation
import Stockpile

final class QuizQuestion: NSManagedObject {

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

        return self.options.contains { $0.correct }
    }

}

extension QuizQuestion: JSONAPIPullable {

    static var type: String {
        return "quiz-questions"
    }

    public func update(from object: ResourceData, with context: SynchronizationContext) throws {
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
