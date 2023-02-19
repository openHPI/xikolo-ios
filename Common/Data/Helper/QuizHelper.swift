//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures
import Foundation
import Stockpile

public enum QuizHelper {

    @discardableResult static public func syncQuizzes(forCourse course: Course) -> Future<Void, XikoloError> {
        return CourseItemHelper.syncCourseItems(forCourse: course, withContentType: "quiz").flatMap { syncResult -> Future<Void, XikoloError> in
            let promise = Promise<Void, XikoloError>()

            CoreDataHelper.persistentContainer.performBackgroundTask { context in
                var quizSyncTasks: [Future<SyncSingleResult, XikoloError>] = []

                for itemObjectId in syncResult.newObjectIds {
                    let item = context.typedObject(with: itemObjectId) as CourseItem
                    guard item.contentType == "quiz" && item.exerciseType == "selftest" else { continue }
                    guard let quiz = item.content as? Quiz else { continue }
                    quizSyncTasks.append(QuizHelper.syncQuiz(quiz))
                }

                let result = quizSyncTasks.sequence().flatMap { _ -> Result<Void, XikoloError> in
                    return context.saveWithResult()
                }

                promise.completeWith(result)
            }

            return promise.future
        }
    }

    @discardableResult static public func syncQuiz(_ quiz: Quiz) -> Future<SyncSingleResult, XikoloError> {
        let fetchRequest = Self.FetchRequest.quiz(withId: quiz.id)
        var query = SingleResourceQuery(resource: quiz)
        query.include("questions")
        return XikoloSyncEngine().synchronize(withFetchRequest: fetchRequest, withQuery: query)
    }

}
