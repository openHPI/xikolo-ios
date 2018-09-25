//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures
import Foundation
import SyncEngine

struct LTIExerciseHelper {

    @discardableResult static func syncLTIExercise(_ ltiExercise: LTIExercise) -> Future<SyncSingleResult, XikoloError> {
        let fetchRequest = LTIExerciseHelper.FetchRequest.ltiExercise(withId: ltiExercise.id)
        let query = SingleResourceQuery(resource: ltiExercise)

        let config = XikoloSyncConfig()
        let strategy = JsonAPISyncStrategy()
        let engine = SyncEngine(configuration: config, strategy: strategy)
        return engine.syncResource(withFetchRequest: fetchRequest, withQuery: query).mapError { error -> XikoloError in
            return .synchronization(error)
        }
    }

}
