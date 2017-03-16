//
//  EnrollmentHelper.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 16.03.17.
//  Copyright © 2017 HPI. All rights reserved.
//

import BrightFutures
import CoreData

class EnrollmentHelper {

    static func getEnrollmentsRequest() -> NSFetchRequest<NSFetchRequestResult> {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Enrollment")
        return request
    }

    static func syncEnrollments() -> Future<[Enrollment], XikoloError> {
        return EnrollmentProvider.getEnrollments().flatMap { spineEnrollments -> Future<[BaseModel], XikoloError> in
            let request = getEnrollmentsRequest()
            return SpineModelHelper.syncObjectsFuture(request, spineObjects: spineEnrollments, inject: nil, save: true)
            }.map { cdEnrollments in
                return cdEnrollments as! [Enrollment]
        }
    }
    
}
