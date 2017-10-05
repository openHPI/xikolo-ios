//
//  TrackingEventResource.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 29.08.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import Foundation

@objcMembers
class TrackingEventResource : NSObject, NSCoding, EmbeddedObject {

    var type: String?
    var uuid: String?

    required init(_ dict: [String : AnyObject]) {
        type = dict["type"] as? String
        uuid = dict["uuid"] as? String
    }

    init?(type: String, uuid: String? = "00000000-0000-0000-0000-000000000000"){
        self.uuid = uuid
        self.type = type
    }
    
    init?(resource: BaseModel) {
        switch (resource) {
            case is CourseItem:
                type = "item"
            case is Announcement:
                 type = "announcement"
            case is Video:
                type = "video"
            default:
                fatalError("Tracking event for unsupported resource: \(resource)")
        }
        uuid = resource.value(forKey: "id") as? String
        if uuid == nil {
            return nil
        }
    }

    func toDict() -> [String : AnyObject] {
        var dict = [String: AnyObject]()
        if let type = type {
            dict["type"] = type as AnyObject?
        }
        if let uuid = uuid {
            dict["uuid"] = uuid as AnyObject?
        }
        return dict
    }

    required init(coder decoder: NSCoder) {
        self.type = decoder.decodeObject(forKey: "type") as? String
        self.uuid = decoder.decodeObject(forKey: "uuid") as? String
    }

    func encode(with coder: NSCoder) {
        coder.encode(self.type, forKey: "type")
        coder.encode(self.uuid, forKey: "uuid")
    }

}
