//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import CoreData
import Foundation

final class Quiz: Content {

    @NSManaged var id: String
    @NSManaged var instructions: String?
    @NSManaged var lockSubmissionsAt: Date?
    @NSManaged var publishResultsAt: Date?
    @NSManaged var showWelcomePage: Bool
    @NSManaged var timeLimit: Int32
    @NSManaged var allowedAttempts: Int32
    @NSManaged private var maxPointsValue: NSDecimalNumber?
    @NSManaged var questions: Set<QuizQuestion>

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Quiz> {
        return NSFetchRequest<Quiz>(entityName: "Quiz")
    }

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

    var formattedTimeLimit: [String] {
        let hours = self.timeLimit / 3600
        let minutes = (self.timeLimit % 3600) / 60
        let seconds = self.timeLimit % 60

        var strings = [String]()
        if hours > 0 {
            let format = NSLocalizedString("%d hours", tableName: "Common", comment: "<number> of hours #bc-ignore!")
            strings.append(String.localizedStringWithFormat(format, hours))
        }

        if minutes > 0 {
            let format = NSLocalizedString("%d minutes", tableName: "Common", comment: "<number> of minutes #bc-ignore!")
            strings.append(String.localizedStringWithFormat(format, minutes))
        }

        if seconds > 0 {
            let format = NSLocalizedString("%d seconds", tableName: "Common", comment: "<number> of seconds #bc-ignore!")
            strings.append(String.localizedStringWithFormat(format, seconds))
        }

        return strings
    }

}

extension Quiz: Pullable {

    static var type: String {
        return "quizzes"
    }

    func update(withObject object: ResourceData, including includes: [ResourceData]?, inContext context: NSManagedObjectContext) throws {
        let attributes = try object.value(for: "attributes") as JSON
        self.instructions = try attributes.value(for: "instructions")
        self.lockSubmissionsAt = try attributes.value(for: "lock_submissions_at")
        self.publishResultsAt = try attributes.value(for: "publish_results_at")
        self.timeLimit = try attributes.value(for: "time_limit")
        self.allowedAttempts = try attributes.value(for: "allowed_attempts")
        self.maxPoints = try attributes.value(for: "max_points")
        self.showWelcomePage = try attributes.value(for: "show_welcome_page")

//        let relationships = try object.value(for: "relationships") as JSON
//        try self.updateRelationship(forKeyPath: \Quiz.questions, forKey: "questions", fromObject: relationships, including: includes, inContext: context)
    }

}
