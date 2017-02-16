//
//  CourseDate.swift
//  xikolo-ios
//
//  Created by Tobias Rohloff on 09.11.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import Foundation
import CoreData
import Spine


class CourseDate : BaseModel {

}

class CourseDateSpine : BaseModelSpine {

    var type: String?
    var title: String?
    var date: Date?

    var course: CourseSpine?

    override class var resourceType: ResourceType {
        return "course-dates"
    }

    override class var cdType: BaseModel.Type {
        return CourseDate.self
    }

    override class var fields: [Field] {
        return fieldsFromDictionary([
            "type": Attribute(),
            "title": Attribute(),
            "date": DateAttribute(),
            "course": ToOneRelationship(CourseSpine.self)
        ])
    }

}
