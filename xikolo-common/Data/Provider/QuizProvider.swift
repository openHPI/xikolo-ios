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

        var query = Query(resourceType: QuizSpine.self, resourceIDs: [quizId])
        query.include("questions")

        return spine.find(query).mapError { error in
            XikoloError.API(error)
        }.flatMap { (resources, _, _) -> Future<QuizSpine, XikoloError> in
            if let quiz = resources[0] as? QuizSpine {
                return Future.init(value: quiz)
            }
            return Future.init(error: XikoloError.InvalidData)
        }
    }

}
