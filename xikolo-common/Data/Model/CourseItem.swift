//
//  CourseItem.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 13.05.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import CoreData
import Foundation
import Spine

class CourseItem : BaseModel {

    var iconName: String? {
        get {
            if let content = content {
                return content.iconName()
            }
            // TODO: better default icon
            return "homework"
        }
    }

    var next: CourseItem? {
        get {
            return neighbor(1)
        }
    }

    var previous: CourseItem? {
        get {
            return neighbor(-1)
        }
    }

    var proctored: Bool {
        get {
            return proctored_int?.boolValue ?? false
        }
        set(new_is_proctored) {
            proctored_int = new_is_proctored as NSNumber?
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

    var visited: Bool? {
        get {
            return visited_int?.boolValue
        }
        set(new_has_visited) {
            visited_int = new_has_visited as NSNumber?
        }
    }

    fileprivate func neighbor(_ direction: Int) -> CourseItem? {
        let items = section?.itemsSorted ?? []
        if var index = items.index(of: self) {
            index += direction
            if index < 0 || index >= items.count {
                return nil
            }
            return items[index]
        }
        return nil
    }

}

class CourseItemSpine : BaseModelSpine {

    var title: String?
    var visited_int: NSNumber?
    var proctored_int: NSNumber?
    var position: NSNumber? // Must be NSNumber, because Int? is not KVC compliant.
    var accessible_int: NSNumber?
    var icon: String?
    var exercise_type: String?
    var deadline: Date?

    var content: BaseModelSpine?

    //used for PATCH
    convenience init(courseItem: CourseItem){
        self.init()
        self.id = courseItem.id
        self.visited_int = courseItem.visited_int
        //TODO: What about content
    }

    override class var cdType: BaseModel.Type {
        return CourseItem.self
    }

    override class var resourceType: ResourceType {
        return "course-items"
    }

    override class var fields: [Field] {
        return fieldsFromDictionary([
            "title": Attribute(),
            "content": ToOneRelationship(ContentSpine.self),
            "visited_int": BooleanAttribute().serializeAs("visited"),
            "proctored_int": BooleanAttribute().serializeAs("proctored"),
            "position": Attribute(),
            "accessible_int": BooleanAttribute().serializeAs("accessible"),
            "icon": Attribute(),
            "exercise_type": Attribute(),
            "deadline": DateAttribute(),
        ])
    }

}
