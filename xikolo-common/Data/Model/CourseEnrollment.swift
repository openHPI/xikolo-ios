//
//  CourseEnrollment.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 26.08.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import CoreData
import Foundation
import Spine

class CourseEnrollment : BaseModel {

    func compare(object: CourseEnrollment) -> NSComparisonResult {
        // This method is required, because we're using an NSSortDescriptor to sort courses based on enrollment.
        // Since we only rely on sorting enrolled vs. un-enrolled courses, this comparison method considers all enrollments equal,
        // which means they will be sorted by the next attribute in the sort descriptor.
        return .OrderedSame
    }

}

class CourseEnrollmentSpine : BaseModelSpine {

    override class var cdType: BaseModel.Type {
        return CourseEnrollment.self
    }

    override class var resourceType: ResourceType {
        return "enrollments"
    }

    override class var fields: [Field] {
        return fieldsFromDictionary([:])
    }

}
