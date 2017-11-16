//
//  QuizHelper+FetchRequests.swift
//  xikolo-ios
//
//  Created by Max Bothe on 16.11.17.
//  Copyright © 2017 HPI. All rights reserved.
//

import CoreData

extension QuizHelper {

    struct FetchRequest {

        static func quiz(withId quizId: String) -> NSFetchRequest<Quiz> {
            let request: NSFetchRequest<Quiz> = Quiz.fetchRequest()
            request.predicate = NSPredicate(format: "id = %@", quizId)
            request.fetchLimit = 1
            return request
        }

    }

}
