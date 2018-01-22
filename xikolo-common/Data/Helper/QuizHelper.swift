//
//  QuizHelper.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 26.07.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import Foundation
import CoreData
import BrightFutures

struct QuizHelper {

    @discardableResult static func syncQuiz(_ quiz: Quiz) -> Future<SyncEngine.SyncSingleResult, XikoloError> {
        let fetchRequest = QuizHelper.FetchRequest.quiz(withId: quiz.id)
        var query = SingleResourceQuery(resource: quiz)
        query.include("questions")
        query.include("submission")
        return SyncHelper.syncResource(withFetchRequest: fetchRequest, withQuery: query)
    }

}
