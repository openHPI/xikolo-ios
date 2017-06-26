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

    var itemsSorted: [CourseItem] {
        if items == nil {
            return []
        }
        return items!.sorted { a, b in
            let a = a as! CourseItem, b = b as! CourseItem
            if a.position == nil || b.position == nil {
                return false
            }
            return UInt(a.position!) < UInt(b.position!)
        } as! [CourseItem]
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
