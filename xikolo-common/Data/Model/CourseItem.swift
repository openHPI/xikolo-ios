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

    override class func spineType() -> Resource.Type {
        return CourseItemSpine.self
    }

    var iconName: String? {
        get {
            if let contentType = self.content_type {
                var iconName: String!
                switch(contentType) {
                case "peer_assessment":
                    iconName = "homework"
                default:
                    iconName = contentType
                }
                return iconName
            }
            return nil
        }
    }

}

class CourseItemSpine : Resource {

    var title: String?
    var content_id: String?
    var content_type: String?

    override class var resourceType: ResourceType {
        return "course-item"
    }

    override class var fields: [Field] {
        return fieldsFromDictionary([
            "title": Attribute(),
            "content_id": Attribute(),
            "content_type": Attribute(),
        ])
    }

}
