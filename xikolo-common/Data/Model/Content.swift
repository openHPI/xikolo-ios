//
//  Content.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 31.05.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import CoreData
import Foundation
import Spine

@objcMembers
class Content : BaseModel {

    func iconName() -> String {
        // TODO: Add "unsupported" icon.
        return "homework"
    }

    var isAvailableOffline: Bool {
        return false
    }

}

@objcMembers
class ContentSpine : BaseModelSpine {

    override class var cdType: BaseModel.Type {
        return Content.self
    }

    override class var resourceType: ResourceType {
        return "unsupported-content"
    }

}
