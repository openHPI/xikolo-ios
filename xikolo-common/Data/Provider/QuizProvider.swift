//
//  QuizProvider.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 26.07.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import BrightFutures
import Foundation
import Spine

class QuizProvider {

    class func getQuiz(quizId: String) -> Future<QuizSpine, XikoloError> {
        let spine = SpineModelHelper.createSpineClient()
        spine.registerResource(QuizSpine)
        spine.registerResource(QuizQuestionSpine)

        return spine.findOne(quizId, ofType: QuizSpine.self).map { tuple in
            tuple.resource
        }.mapError { error in
            XikoloError.API(error)
        }.flatMap { (quiz: QuizSpine) -> Future<QuizSpine, XikoloError> in
            if let questions = quiz.questions {
                return spine.find(Query(resourceType: QuizQuestionSpine.self, resourceCollection: questions)).map { resources, _, _ in
                    quiz.questions = resources
                    return quiz
                }.mapError { error in
                    XikoloError.API(error)
                }
            } else {
                return Future.init(error: XikoloError.InvalidData)
            }
        }
    }

}
