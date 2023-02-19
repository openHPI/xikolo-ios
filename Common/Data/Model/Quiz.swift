//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import CoreData
import Foundation
import Stockpile

public final class Quiz: Content {

    @NSManaged public var id: String
    @NSManaged public var instructions: String?
    @NSManaged public var timeLimit: Int32
    @NSManaged public var allowedAttempts: Int32
    @NSManaged public var questions: Set<QuizQuestion>

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Quiz> {
        return NSFetchRequest<Quiz>(entityName: "Quiz")
    }

}

extension Quiz: JSONAPIPullable {

    public static var type: String {
        return "quizzes"
    }

    public func update(from object: ResourceData, with context: SynchronizationContext) throws {
        let attributes = try object.value(for: "attributes") as JSON
        self.instructions = try attributes.value(for: "instructions")
        self.timeLimit = try attributes.value(for: "time_limit")
        self.allowedAttempts = try attributes.value(for: "allowed_attempts")

        let relationships = try object.value(for: "relationships") as JSON
        try self.updateRelationship(forKeyPath: \Self.questions, forKey: "questions", fromObject: relationships, with: context)
    }

}
