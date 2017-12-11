//
//  LTIExerciseHelper+FetchRequests.swift
//  xikolo-ios
//
//  Created by Max Bothe on 15.11.17.
//  Copyright © 2017 HPI. All rights reserved.
//

import CoreData

extension LTIExerciseHelper {

    struct FetchRequest {

        static func ltiExercise(withId id: String) -> NSFetchRequest<LTIExercise> {
            let request: NSFetchRequest<LTIExercise> = LTIExercise.fetchRequest()
            return request
        }

    }

}
