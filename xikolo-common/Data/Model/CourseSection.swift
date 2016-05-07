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

class CourseSectionSpine : Resource {

    var title: String?
    var section_description: String?

    override class var resourceType: ResourceType {
        return "course-section"
    }

    override class var fields: [Field] {
        return fieldsFromDictionary([
            "title": Attribute(),
            "section_description": Attribute().serializeAs("description"),
        ])
    }

}
