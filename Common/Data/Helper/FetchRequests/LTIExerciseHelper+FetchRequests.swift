//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import CoreData

extension LTIExerciseHelper {

    enum FetchRequest {

        static func ltiExercise(withId id: String) -> NSFetchRequest<LTIExercise> {
            let request: NSFetchRequest<LTIExercise> = LTIExercise.fetchRequest()
            return request
        }

    }

}
