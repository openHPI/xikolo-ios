//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures
import Foundation
import Stockpile

enum LTIExerciseHelper {

    @discardableResult static func syncLTIExercise(_ ltiExercise: LTIExercise) -> Future<SyncSingleResult, XikoloError> {
        let fetchRequest = Self.FetchRequest.ltiExercise(withId: ltiExercise.id)
        let query = SingleResourceQuery(resource: ltiExercise)
        return XikoloSyncEngine().synchronize(withFetchRequest: fetchRequest, withQuery: query)
    }

}
