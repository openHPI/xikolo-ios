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

    var visited: Bool? {
        get {
            return visited_int?.boolValue
        }
        set(new_has_visited) {
            visited_int = new_has_visited
        }
    }

    private func neighbor(direction: Int) -> CourseItem? {
        let items = section?.itemsSorted ?? []
        if var index = items.indexOf(self) {
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
    var position: NSNumber? // Must be NSNumber, because Int? is not KVC compliant.

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
            "content": ToOneRelationship(ContentSpine),
            "visited_int": Attribute().serializeAs("visited"),
            "position": Attribute(),
        ])
    }

}
