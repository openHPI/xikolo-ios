//
//  LTIExerciseHelper.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 18.09.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import Foundation
import BrightFutures

struct LTIExerciseHelper {

    static func syncLTIExercise(_ ltiExercise: LTIExercise) -> Future<LTIExercise, XikoloError> {
        let fetchRequest = LTIExerciseHelper.FetchRequest.ltiExercise(withId: ltiExercise.id)
        let query = SingleResourceQuery(resource: ltiExercise)
        return SyncEngine.syncResource(withFetchRequest: fetchRequest, withQuery: query)
    }

}

//import BrightFutures
//import Foundation
//
//class LTIExerciseHelper {
//
//    static func refreshLTIExercise(_ ltiExercise: LTIExercise) -> Future<LTIExercise, XikoloError> {
//        return LTIExerciseProvider.getLTIExercise(ltiExercise.id).flatMap { spineLTIExercise -> Future<[LTIExercise], XikoloError> in
//            return SpineModelHelper.syncObjectsFuture([ltiExercise], spineObjects: [spineLTIExercise], inject: nil, save: true)
//        }.map{ cdLTIExercises in
//            return cdLTIExercises[0]
//        }
//    }
//
//}

