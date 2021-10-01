//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import CoreData

extension QuizHelper {

    enum FetchRequest {

        static func quiz(withId quizId: String) -> NSFetchRequest<Quiz> {
            let request: NSFetchRequest<Quiz> = Quiz.fetchRequest()
            request.predicate = NSPredicate(format: "id = %@", quizId)
            request.fetchLimit = 1
            return request
        }

    }

}
