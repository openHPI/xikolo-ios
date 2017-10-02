//
//  PlatformEvent.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 07.09.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import Foundation
import CoreData
import Spine

@objcMembers
class PlatformEvent : BaseModel {

}

@objcMembers
class PlatformEventSpine : BaseModelSpine {

    var created_at: Date?
    var preview: String?
    var title: String?
    var type: String?

    var course: CourseSpine?

    override class var cdType: BaseModel.Type {
        return PlatformEvent.self
    }

    override class var resourceType: ResourceType {
        return "platform-events"
    }

    override class var fields: [Field] {
        return fieldsFromDictionary([
            "title": Attribute(),
            "type": Attribute(),
            "created_at": DateAttribute(),
            "preview": Attribute(),
            "course": ToOneRelationship(CourseSpine.self),
        ])
    }
}
