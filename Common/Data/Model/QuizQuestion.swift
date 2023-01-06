//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import CoreData
import Foundation
import Stockpile

public final class QuizQuestion: NSManagedObject {

    @NSManaged public var id: String
    @NSManaged public var text: String?
    @NSManaged public var explanation: String?
    @NSManaged public var type: String?
    @NSManaged public var position: Int32
    @NSManaged public var shuffleOptions: Bool
    @NSManaged public var eligibleForRecap: Bool
    @NSManaged public var options: [QuizQuestionOption]
    @NSManaged public var quiz: Quiz?

    public var questionType: QuizQuestionType {
        guard let type = self.type else { return .unsupported }
        return QuizQuestionType.fromString(type)
    }

    @nonobjc public class func fetchRequest() -> NSFetchRequest<QuizQuestion> {
        return NSFetchRequest<QuizQuestion>(entityName: "QuizQuestion")
    }

}

extension QuizQuestion: JSONAPIPullable {

    public static var type: String {
        return "quiz-questions"
    }

    public func update(from object: ResourceData, with context: SynchronizationContext) throws {
        let attributes = try object.value(for: "attributes") as JSON
        self.text = try attributes.value(for: "text")
        self.explanation = try attributes.value(for: "explanation")
        self.type = try attributes.value(for: "type")
        self.shuffleOptions = try attributes.value(for: "shuffle_options")
        self.position = try attributes.value(for: "position")
        self.eligibleForRecap = try attributes.value(for: "eligible_for_recap")
        self.options = try attributes.value(for: "options")
    }

}

public enum QuizQuestionType {

    case singleAnswer
    case multipleAnswer
    case unsupported

    static func fromString(_ string: String) -> QuizQuestionType {
        switch string {
        case "select_one":
            return .singleAnswer
        case "select_multiple":
            return .multipleAnswer
        default:
            return .unsupported
        }
    }

}
