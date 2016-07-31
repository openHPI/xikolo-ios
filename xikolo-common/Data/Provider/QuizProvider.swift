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

        return spine.findOne(quizId, ofType: QuizSpine.self).map { tuple in
            tuple.resource
        }.mapError { error in
            XikoloError.API(error)
        }
    }

}
