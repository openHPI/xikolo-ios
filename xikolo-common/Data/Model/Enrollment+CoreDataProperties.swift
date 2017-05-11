//
//  CourseEnrollment+CoreDataProperties.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 26.08.16.
//  Copyright © 2016 HPI. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Enrollment {

    @NSManaged var id: String
    @NSManaged var visits: EnrollmentVisits?
    @NSManaged var points: EnrollmentPoints?
    @NSManaged var certificates: EnrollmentCertificates?
    @NSManaged var proctored_int: NSNumber?
    @NSManaged var completed_int: NSNumber?
    @NSManaged var reactivated_int: NSNumber?
    @NSManaged var course: Course?

}
