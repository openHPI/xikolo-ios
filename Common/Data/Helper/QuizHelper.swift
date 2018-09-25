//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures
import Foundation
import SyncEngine

struct QuizHelper {

    @discardableResult static func syncQuiz(_ quiz: Quiz) -> Future<SyncSingleResult, XikoloError> {
        let fetchRequest = QuizHelper.FetchRequest.quiz(withId: quiz.id)
        var query = SingleResourceQuery(resource: quiz)
        query.include("questions")
        query.include("submission")

        let engine = XikoloSyncEngine()
        return engine.syncResource(withFetchRequest: fetchRequest, withQuery: query).mapError { error -> XikoloError in
            return .synchronization(error)
        }
    }

}
