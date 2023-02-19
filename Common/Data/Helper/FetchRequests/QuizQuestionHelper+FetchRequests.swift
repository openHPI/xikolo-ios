//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import CoreData

public enum QuizQuestionHelper {

    public enum FetchRequest {

        public static func questionsForRecap(in course: Course,
                                             limitedToSectionsWithIds sectionIds: Set<String> = [],
                                             onlyVisitedItems: Bool = false) -> NSFetchRequest<QuizQuestion> {
            let request: NSFetchRequest<QuizQuestion> = QuizQuestion.fetchRequest()

            let sectionPredicate: NSPredicate = {
                if sectionIds.isEmpty {
                    return NSPredicate(value: true)
                } else {
                    return NSPredicate(format: "quiz.item.section.id in %@", sectionIds.map(NSString.init(string:)))
                }
            }()

            let visitedPredicate: NSPredicate = {
                if onlyVisitedItems {
                    return NSPredicate(format: "quiz.item.visited = %@", NSNumber(value: true))
                } else {
                    return NSPredicate(value: true)
                }
            }()

            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                NSPredicate(format: "eligibleForRecap = %@", NSNumber(value: true)),
                NSPredicate(format: "quiz.item.exerciseType = %@", NSString(string: "selftest")),
                NSPredicate(format: "quiz.item.section.course = %@", course),
                sectionPredicate,
                visitedPredicate,
            ])

            return request
        }

    }

}
