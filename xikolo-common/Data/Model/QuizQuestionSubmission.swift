//
//  QuizQuestionSubmission.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 21.08.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import Foundation

class QuizQuestionSubmission : NSObject, EmbeddedDictObject {

    var key: String? {
        return question?.id ?? questionID
    }

    var answers: [String]?
    var text: String?
    var unsupportedData: AnyObject?

    var questionID: String?
    var question: QuizQuestion?

    required init?(key: String, data: AnyObject) {
        guard let dict = data as? [String: AnyObject] else {
            return nil
        }
        guard let type = dict["type"] as? String else {
            return nil
        }
        self.questionID = key

        let questionType = QuizQuestionType.fromString(type)
        switch (questionType) {
            case .SingleAnswer:
                answers = []
                if let id = dict["data"] as? String {
                    answers?.append(id)
                }
            case .MultipleAnswer:
                answers = dict["data"] as? [String]
            case .FreeText:
                text = dict["data"] as? String
            case .Unsupported:
                unsupportedData = dict["data"]
        }
    }

    init(question: QuizQuestion) {
        self.question = question
    }

    func data() -> AnyObject {
        var data: AnyObject!

        // At this point we can assume the question has been set (see QuizHelper).
        switch (question!.questionType) {
            case .SingleAnswer:
                data = answers?.first ?? NSNull()
            case .MultipleAnswer:
                data = answers ?? NSNull()
            case .FreeText:
                data = text ?? NSNull()
            case .Unsupported:
                data = unsupportedData ?? NSNull()
        }

        let ret: [String: AnyObject] = [
            "type": question!.type!,
            "data": data,
        ]
        return ret
    }

}
