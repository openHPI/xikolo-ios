//
//  LTIExerciseHelper.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 18.09.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import Foundation
import CoreData
import BrightFutures

struct LTIExerciseHelper {

    @discardableResult static func syncLTIExercise(_ ltiExercise: LTIExercise) -> Future<SyncEngine.SyncSingleResult, XikoloError> {
        let fetchRequest = LTIExerciseHelper.FetchRequest.ltiExercise(withId: ltiExercise.id)
        let query = SingleResourceQuery(resource: ltiExercise)
        return SyncHelper.syncResource(withFetchRequest: fetchRequest, withQuery: query)
    }

}
