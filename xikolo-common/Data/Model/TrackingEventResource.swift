//
//  TrackingEventResource.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 29.08.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import Foundation

class TrackingEventResource : NSObject, NSCoding {

    var resourceType: String
    var uuid: String

    static func noneResource() -> TrackingEventResource {
        return TrackingEventResource(resourceType: "None")
    }

    private init(resourceType: String) {
        self.resourceType = resourceType
        self.uuid = "00000000-0000-0000-0000-000000000000"
    }

    init(resource: Pullable) {
        self.resourceType = type(of: resource).type
        self.uuid = resource.id
    }

    init(resourceType: Pullable.Type) {
        self.resourceType = resourceType.type
        self.uuid = "00000000-0000-0000-0000-000000000000"
    }

    required init?(coder decoder: NSCoder) {
        guard let uuid = decoder.decodeObject(forKey: "uuid") as? String,
            let type = decoder.decodeObject(forKey: "type") as? String else {
            return nil
        }

        self.resourceType = type
        self.uuid = uuid
    }

    func encode(with coder: NSCoder) {
        coder.encode(self.resourceType, forKey: "type")
        coder.encode(self.uuid, forKey: "uuid")
    }

//    required init(_ dict: [String : AnyObject]) {
//        type = dict["type"] as? String
//        uuid = dict["uuid"] as? String
//    }

//    init?(type: String, uuid: String? = "00000000-0000-0000-0000-000000000000"){
//        self.uuid = uuid
//        self.type = type
//    }

//    init?(resource: BaseModel) {
//        switch (resource) {
//            case is CourseItem:
//                type = "item"
//            case is Announcement:
//                 type = "announcement"
//            case is Video:
//                type = "video"
//            default:
//                fatalError("Tracking event for unsupported resource: \(resource)")
//        }
//        uuid = resource.value(forKey: "id") as? String
//        if uuid == nil {
//            return nil
//        }
//    }

//    func toDict() -> [String : AnyObject] {
//        var dict = [String: AnyObject]()
//        if let type = type {
//            dict["type"] = type as AnyObject?
//        }
//        if let uuid = uuid {
//            dict["uuid"] = uuid as AnyObject?
//        }
//        return dict
//    }

}
