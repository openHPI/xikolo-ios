//
//  LTIExerciseHelper.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 18.09.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import BrightFutures
import Foundation
import Result

class LTIExerciseHelper {

    static func refreshLTIExercise(_ ltiExercise: LTIExercise) -> Future<LTIExercise, XikoloError> {
        return LTIExerciseProvider.getLTIExercise(ltiExercise.id).flatMap { spineLTIExercise -> Future<[LTIExercise], XikoloError> in
            return SpineModelHelper.syncObjectsFuture([ltiExercise], spineObjects: [spineLTIExercise], inject: nil, save: true)
        }.map{ cdLTIExercises in
            return cdLTIExercises[0]
        }
    }
    
}
