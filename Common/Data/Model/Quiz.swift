//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import CoreData
import Foundation
import Stockpile

final class Quiz: Content {

    @NSManaged var id: String
    @NSManaged var instructions: String?
    @NSManaged var lockSubmissionsAt: Date?
    @NSManaged var publishResultsAt: Date?
    @NSManaged var timeLimit: Int32
    @NSManaged var allowedAttempts: Int32
    @NSManaged var questions: Set<QuizQuestion>

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Quiz> {
        return NSFetchRequest<Quiz>(entityName: "Quiz")
    }

}

extension Quiz: JSONAPIPullable {

    static var type: String {
        return "quizzes"
    }

    public func update(from object: ResourceData, with context: SynchronizationContext) throws {
        let attributes = try object.value(for: "attributes") as JSON
        self.instructions = try attributes.value(for: "instructions")
        self.lockSubmissionsAt = try attributes.value(for: "lock_submissions_at")
        self.publishResultsAt = try attributes.value(for: "publish_results_at")
        self.timeLimit = try attributes.value(for: "time_limit")
        self.allowedAttempts = try attributes.value(for: "allowed_attempts")

//        let relationships = try object.value(for: "relationships") as JSON
//        try self.updateRelationship(forKeyPath: \Self.questions, forKey: "questions", fromObject: relationships, including: includes, inContext: context)
    }

}
