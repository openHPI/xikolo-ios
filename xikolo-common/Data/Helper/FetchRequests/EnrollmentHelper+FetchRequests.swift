//
//  EnrollmentHelper+FetchRequests.swift
//  xikolo-ios
//
//  Created by Max Bothe on 15.11.17.
//  Copyright © 2017 HPI. All rights reserved.
//

import CoreData

extension EnrollmentHelper {

    struct FetchRequest {

        static var allEnrollements: NSFetchRequest<Enrollment> {
            let request: NSFetchRequest<Enrollment> = Enrollment.fetchRequest()
            return request
        }

    }

}
