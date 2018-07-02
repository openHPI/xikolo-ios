//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures
import Foundation

struct LTIExerciseHelper {

    @discardableResult static func syncLTIExercise(_ ltiExercise: LTIExercise) -> Future<SyncEngine.SyncSingleResult, XikoloError> {
        let fetchRequest = LTIExerciseHelper.FetchRequest.ltiExercise(withId: ltiExercise.id)
        let query = SingleResourceQuery(resource: ltiExercise)
        return SyncEngine.shared.syncResource(withFetchRequest: fetchRequest, withQuery: query)
    }

}
