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

}

class CourseItemSpine : BaseModelSpine {

    var title: String?

    var content: BaseModelSpine?

    override class var cdType: BaseModel.Type {
        return CourseItem.self
    }

    override class var resourceType: ResourceType {
        return "course-items"
    }

    override class var fields: [Field] {
        return fieldsFromDictionary([
            "title": Attribute(),
            "content": ToOneRelationship(VideoSpine),
        ])
    }

}
