//
//  QuizQuestionSubmission.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 21.08.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import Foundation

@objcMembers
class QuizQuestionSubmission : NSObject, EmbeddedDictObject {

    var key: String? {
        return question?.id ?? questionID
    }

    var answers: [String]?
    var text: String?
    var unsupportedData: AnyObject?

    var questionID: String?
    var question: QuizQuestion?

    var correctness: Float? {
        guard let question = question, let answers = answers else {
            return nil
        }
        if !question.hasCorrectnessData {
            return nil
        }
        switch (question.questionType) {
            case .singleAnswer, .multipleAnswer:
                guard let questionOptions = question.options else {
                    return nil
                }

                var baseScore = 0
                questionOptions.forEach { answer in
                    let correct = answer.correct ?? false
                    let answerSelected = answers.contains(answer.id!)
                    if answerSelected && correct {
                        baseScore += 1
                    } else if answerSelected && !correct {
                        baseScore -= 1
                    }
                }
                if baseScore < 0 {
                    baseScore = 0
                }
                return Float(baseScore) / Float(questionOptions.filter({ $0.correct ?? false }).count)
            case .unsupported:
                return nil
        }
    }

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
            case .singleAnswer:
                answers = []
                if let id = dict["data"] as? String {
                    answers?.append(id)
                }
            case .multipleAnswer:
                answers = dict["data"] as? [String]
            // case .freeText:
            //     text = dict["data"] as? String
            case .unsupported:
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
            case .singleAnswer:
                data = answers?.first as AnyObject?? ?? NSNull()
            case .multipleAnswer:
                data = answers as AnyObject?? ?? NSNull()
            // case .freeText:
            //     data = text as AnyObject?? ?? NSNull()
            case .unsupported:
                data = unsupportedData ?? NSNull()
        }

        let ret: [String: AnyObject] = [
            "type": question!.type! as AnyObject,
            "data": data,
        ]
        return ret as AnyObject
    }

}
