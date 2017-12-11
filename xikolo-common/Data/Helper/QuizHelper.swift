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

    static func syncQuiz(_ quiz: Quiz) -> Future<NSManagedObjectID, XikoloError> {
        let fetchRequest = QuizHelper.FetchRequest.quiz(withId: quiz.id)
        var query = SingleResourceQuery(resource: quiz)
        query.include("questions")
        query.include("submission")
        return SyncEngine.syncResource(withFetchRequest: fetchRequest, withQuery: query)
    }

}
