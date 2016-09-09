//
//  QuizHelper.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 26.07.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import BrightFutures
import Foundation
import Result

class QuizHelper {

    static func refreshQuiz(quiz: Quiz) -> Future<Quiz, XikoloError> {
        return QuizProvider.getQuiz(quiz.id).flatMap { spineQuiz -> Future<[BaseModel], XikoloError> in
            return SpineModelHelper.syncObjectsFuture([quiz], spineObjects: [spineQuiz], inject: nil, save: true)
        }.map { cdQuizzes in
            return cdQuizzes[0] as! Quiz
        }.onSuccess { quiz in
            if let questions = quiz.questions, submissions = quiz.submission?.answers {
                for question in questions {
                    let submission = submissions[question.id]
                    question.submission = submission
                    submission?.question = question
                }
            }
        }
    }

    static func saveSubmission(submission: QuizSubmission) -> Future<QuizSubmission, XikoloError> {
        return SpineHelper.save(submission)
    }

}
