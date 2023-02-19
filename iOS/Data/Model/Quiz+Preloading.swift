//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

//import BrightFutures
//import Common
//import Stockpile
//
//extension Quiz: PreloadableCourseItemContent {
//
//    static var contentType: String {
//        return "quiz"
//    }
//
//    static func preloadContent(forCourse course: Course) -> Future<SyncMultipleResult, XikoloError> {
//        return CourseItemHelper.syncCourseItems(forCourse: course, withContentType: self.contentType).onSuccess { syncResult in
//            CoreDataHelper.persistentContainer.performBackgroundTask { context in
//                for itemObjectId in syncResult.newObjectIds {
//                    let item = context.typedObject(with: itemObjectId) as CourseItem
//                    guard item.contentType == "quiz" && item.exerciseType == "selftest" else { continue }
//                    guard let quiz = item.content as? Quiz else { continue }
//                    QuizHelper.syncQuiz(quiz)
//                }
//            }
//        }
//    }
//
//}
