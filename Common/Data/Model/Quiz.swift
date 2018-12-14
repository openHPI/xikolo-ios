//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import CoreData
import Foundation
import SyncEngine

public final class Quiz: Content {

    @NSManaged public var id: String
    @NSManaged public var instructions: String?
    @NSManaged public var lockSubmissionsAt: Date?
    @NSManaged public var publishResultsAt: Date?
    @NSManaged public var showWelcomePage: Bool
    @NSManaged public var timeLimit: Int32
    @NSManaged public var allowedAttempts: Int32
    @NSManaged var questions: Set<QuizQuestion>

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Quiz> {
        return NSFetchRequest<Quiz>(entityName: "Quiz")
    }

    var formattedTimeLimit: [String] {
        let hours = self.timeLimit / 3600
        let minutes = (self.timeLimit % 3600) / 60
        let seconds = self.timeLimit % 60

        var strings = [String]()
        if hours > 0 {
            let format = CommonLocalizedString("%d hours", comment: "<number> of hours #bc-ignore!")
            strings.append(String.localizedStringWithFormat(format, hours))
        }

        if minutes > 0 {
            let format = CommonLocalizedString("%d minutes", comment: "<number> of minutes #bc-ignore!")
            strings.append(String.localizedStringWithFormat(format, minutes))
        }

        if seconds > 0 {
            let format = CommonLocalizedString("%d seconds", comment: "<number> of seconds #bc-ignore!")
            strings.append(String.localizedStringWithFormat(format, seconds))
        }

        return strings
    }

}

extension Quiz: JSONAPIPullable {

    public static var type: String {
        return "quizzes"
    }

    public func update(from object: ResourceData, with context: SynchronizationContext) throws {
        let attributes = try object.value(for: "attributes") as JSON
        self.instructions = try attributes.value(for: "instructions")
        self.lockSubmissionsAt = try attributes.value(for: "lock_submissions_at")
        self.publishResultsAt = try attributes.value(for: "publish_results_at")
        self.timeLimit = try attributes.value(for: "time_limit")
        self.allowedAttempts = try attributes.value(for: "allowed_attempts")
        self.showWelcomePage = try attributes.value(for: "show_welcome_page")

//        let relationships = try object.value(for: "relationships") as JSON
//        try self.updateRelationship(forKeyPath: \Quiz.questions, forKey: "questions", fromObject: relationships, including: includes, inContext: context)
    }

}
