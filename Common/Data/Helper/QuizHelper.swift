//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures
import Foundation
import Stockpile

enum QuizHelper {

    @discardableResult static func syncQuiz(_ quiz: Quiz) -> Future<SyncSingleResult, XikoloError> {
        let fetchRequest = Self.FetchRequest.quiz(withId: quiz.id)
        var query = SingleResourceQuery(resource: quiz)
        query.include("questions")
        query.include("submission")
        return XikoloSyncEngine().synchronize(withFetchRequest: fetchRequest, withQuery: query)
    }

}
