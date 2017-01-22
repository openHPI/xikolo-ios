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

    var correctness: Float? {
        guard let question = question, answers = answers else {
            return nil
        }
        if !question.hasCorrectnessData {
            return nil
        }
        switch (question.questionType) {
            case .SingleAnswer, .MultipleAnswer:
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
            case .FreeText, .Unsupported:
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
