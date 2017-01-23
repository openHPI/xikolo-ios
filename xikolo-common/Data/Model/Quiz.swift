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

    var submission: QuizSubmission?

    var time_limit_formatted: [String] {
        guard let time_limit = time_limit?.intValue else {
            return []
        }

        let hours = time_limit / 3600
        let minutes = (time_limit % 3600) / 60
        let seconds = time_limit % 60

        var strings = [String]()
        if hours > 0 {
            let format = NSLocalizedString("%d hour(s)", comment: "<number> hours")
            strings.append(String.localizedStringWithFormat(format, hours))
        }
        if minutes > 0 {
            let format = NSLocalizedString("%d minute(s)", comment: "<number> minutes")
            strings.append(String.localizedStringWithFormat(format, minutes))
        }
        if seconds > 0 {
            let format = NSLocalizedString("%d second(s)", comment: "<number> seconds")
            strings.append(String.localizedStringWithFormat(format, seconds))
        }

        return strings
    }

    var show_welcome_page: Bool {
        get {
            return show_welcome_page_int?.boolValue ?? false
        }
        set(new_show_welcome_page) {
            show_welcome_page_int = new_show_welcome_page as NSNumber?
        }
    }

    override func iconName() -> String {
        return "quiz"
    }

}

class QuizSpine : ContentSpine {

    var instructions: String?
    var lock_submissions_at: Date?
    var publish_results_at: Date?
    var time_limit: NSNumber?
    var allowed_attempts: NSNumber?
    var max_points: NSDecimalNumber?
    var show_welcome_page_int: NSNumber?

    var questions: ResourceCollection?
    var submission: QuizSubmission?

    required init() {
        super.init()
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
    }

    init(id: String) {
        super.init()
        self.id = id
    }

    override class var cdType: BaseModel.Type {
        return Quiz.self
    }

    override class var resourceType: ResourceType {
        return "quizzes"
    }

    override class var fields: [Field] {
        return fieldsFromDictionary([
            "instructions": Attribute(),
            "lock_submissions_at": DateAttribute(),
            "publish_results_at": DateAttribute(),
            "time_limit": Attribute(),
            "allowed_attempts": Attribute(),
            "max_points": Attribute(),
            "show_welcome_page_int": Attribute().serializeAs("show_welcome_page"),
            "questions": ToManyRelationship(QuizQuestionSpine.self),
            "submission": ToOneRelationship(QuizSubmission.self).serializeAs("newest_user_submission"),
        ])
    }

}
