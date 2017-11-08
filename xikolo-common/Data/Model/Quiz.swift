//
//  Quiz.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 31.05.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import CoreData
import Foundation
import Spine

class Quiz : Content {

    @NSManaged var id: String
    @NSManaged var instructions: String?
    @NSManaged var lockSubmissionsAt: Date?
    @NSManaged var publishResultsAt: Date?
    @NSManaged var showWelcomePage: Bool
    @NSManaged var timeLimit: Int32
    @NSManaged var allowedAttempts: Int32
    @NSManaged private var maxPointsValue: NSDecimalNumber?
    @NSManaged var questions: Set<QuizQuestion>?

    var submission: QuizSubmission?

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

    var time_limit_formatted: [String] {
//        guard let time_limit = self.timeLimit?.intValue else {
//            return []
//        }

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

//    var show_welcome_page: Bool {
//        get {
//            return show_welcome_page_int?.boolValue ?? false
//        }
//        set(new_show_welcome_page) {
//            show_welcome_page_int = new_show_welcome_page as NSNumber?
//        }
//    }

    override func iconName() -> String {
        return "quiz"
    }

}

extension Quiz : Pullable {

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

        let relationships = try object.value(for: "relationships") as JSON
        try self.updateRelationship(forKeyPath: \Quiz.questions, forKey: "questions", fromObject: relationships, including: includes, inContext: context)
        // TODO: submission
    }

}

//@objcMembers
//class QuizSpine : ContentSpine {
//
//    var instructions: String?
//    var lock_submissions_at: Date?
//    var publish_results_at: Date?
//    var time_limit: NSNumber?
//    var allowed_attempts: NSNumber?
//    var max_points: NSDecimalNumber?
//    var show_welcome_page_int: NSNumber?
//
//    var questions: ResourceCollection?
//    var submission: QuizSubmission?
//
//    required init() {
//        super.init()
//    }
//
//    required init(coder: NSCoder) {
//        super.init(coder: coder)
//    }
//
//    init(id: String) {
//        super.init()
//        self.id = id
//    }
//
//    override class var cdType: BaseModel.Type {
//        return Quiz.self
//    }
//
//    override class var resourceType: ResourceType {
//        return "quizzes"
//    }
//
//    override class var fields: [Field] {
//        return fieldsFromDictionary([
//            "instructions": Attribute(),
//            "lock_submissions_at": DateAttribute(),
//            "publish_results_at": DateAttribute(),
//            "time_limit": Attribute(),
//            "allowed_attempts": Attribute(),
//            "max_points": Attribute(),
//            "show_welcome_page_int": BooleanAttribute().serializeAs("show_welcome_page"),
//            "questions": ToManyRelationship(QuizQuestionSpine.self),
//            "submission": ToOneRelationship(QuizSubmission.self).serializeAs("newest_user_submission"),
//        ])
//    }
//
//}

