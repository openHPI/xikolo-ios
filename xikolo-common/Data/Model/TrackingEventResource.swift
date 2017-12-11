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

    init(resource: ResourceRepresentable) {
        self.resourceType = type(of: resource).type
        self.uuid = resource.id
    }

    init(resourceType: ResourceRepresentable.Type) {
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

}

extension TrackingEventResource : IncludedPushable {

    func resourceAttributes() -> [String : Any] {
        return [
            "type": self.resourceType,
            "uuid": self.uuid,
        ]
    }

}
