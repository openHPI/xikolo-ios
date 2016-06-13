//
//  CourseSection.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 04.05.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import CoreData
import Foundation
import Spine

class CourseSection : BaseModel {

}

class CourseSectionSpine : BaseModelSpine {

    var title: String?
    var section_description: String?
    var position: NSNumber? // Must be NSNumber, because Int? is not KVC compliant.
    
    override class var cdType: BaseModel.Type {
        return CourseSection.self
    }

    override class var resourceType: ResourceType {
        return "course-sections"
    }

    override class var fields: [Field] {
        return fieldsFromDictionary([
            "title": Attribute(),
            "section_description": Attribute().serializeAs("description"),
            "position": Attribute(),
        ])
    }

}
