//
//  QuizSubmission.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 21.08.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import Foundation
import Spine

class QuizSubmission : Resource {

    var submitted: Bool {
        get { return submitted_int == 1 }
        set { submitted_int = newValue as NSNumber? }
    }

    var created_at: Date?
    var submitted_at: Date?
    var submitted_int: NSNumber?
    var points: NSNumber?
    var answers: [String: QuizQuestionSubmission]?
    var quiz: QuizSpine?

    override class var resourceType: ResourceType {
        return "quiz-submissions"
    }

    override class var fields: [Field] {
        return fieldsFromDictionary([
            "created_at": DateAttribute(),
            "submitted_at": DateAttribute(),
            "submitted_int": Attribute().serializeAs("submitted"),
            "points": Attribute(),
            "answers": EmbeddedDictAttribute(QuizQuestionSubmission.self),
            "quiz": ToOneRelationship(QuizSpine.self),
        ])
    }

}
