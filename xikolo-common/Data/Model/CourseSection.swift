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

@objcMembers
class CourseSection : BaseModel {

    var itemsSorted: [CourseItem] {
        guard let courseItems = self.items?.allObjects as? [CourseItem] else {
            return []
        }

        return courseItems.sorted {
            guard let firstPosition = $0.position, let secondPosition = $1.position else {
                return false
            }

            return firstPosition.uintValue < secondPosition.uintValue
        }
    }

    var accessible: Bool {
        get {
            return accessible_int?.boolValue ?? false
        }
        set(new_is_accessible) {
            accessible_int = new_is_accessible as NSNumber?
        }
    }

    var sectionName: String? {
        return self.title
    }

}

@objcMembers
class CourseSectionSpine : BaseModelSpine {

    var title: String?
    var section_description: String?
    var position: NSNumber? // Must be NSNumber, because Int? is not KVC compliant.
    var start_at: Date?
    var end_at: Date?
    var accessible_int: NSNumber?

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
            "start_at": DateAttribute(),
            "end_at": DateAttribute(),
            "accessible_int": BooleanAttribute().serializeAs("accessible"),
        ])
    }

}
