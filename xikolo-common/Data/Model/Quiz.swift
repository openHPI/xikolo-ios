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

    var show_welcome_page: Bool {
        get {
            return show_welcome_page_int?.boolValue ?? false
        }
        set(new_show_welcome_page) {
            show_welcome_page_int = new_show_welcome_page
        }
    }

    override func iconName() -> String {
        return "quiz"
    }

}

class QuizSpine : ContentSpine {

    var instructions: String?
    var lock_submissions_at: NSDate?
    var publish_results_at: NSDate?
    var time_limit: NSNumber?
    var allowed_attempts: NSNumber?
    var max_points: NSDecimalNumber?
    var show_welcome_page_int: NSNumber?

    var questions: ResourceCollection?

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
        ])
    }

}
