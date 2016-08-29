//
//  TrackingEventResource.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 29.08.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import Foundation

class TrackingEventResource : NSObject, EmbeddedObject {

    var type: String?
    var uuid: String?

    required init(_ dict: [String : AnyObject]) {
        if let type = dict["type"] as? String {
            self.type = type
        }
        if let uuid = dict["uuid"] as? String {
            self.uuid = uuid
        }
    }

    init?(resource: BaseModel) {
        switch (resource) {
            case is CourseItem:
                type = "item"
            default:
                fatalError("Tracking event for unsupported resource: \(resource)")
        }
        uuid = resource.valueForKey("id") as? String
        if uuid == nil {
            return nil
        }
    }

    func toDict() -> [String : AnyObject] {
        var dict = [String: AnyObject]()
        if let type = type {
            dict["type"] = type
        }
        if let uuid = uuid {
            dict["uuid"] = uuid
        }
        return dict
    }

}
