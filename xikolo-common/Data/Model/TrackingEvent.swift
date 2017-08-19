//
//  TrackingEvent.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 16.08.17.
//  Copyright © 2017 HPI. All rights reserved.
//
//

import Foundation
import CoreData
import Spine

public class TrackingEvent: NSManagedObject {


}

class TrackingEventSpine : Resource {

    var user: TrackingEventUser?
    var verb: TrackingEventVerb?
    var resource: TrackingEventResource?
    var timestamp: Date?
    var result: [String: AnyObject]?
    var context: [String: AnyObject]?

    override class var resourceType: ResourceType {
        return "tracking-events"
    }

    override class var fields: [Field] {
        return fieldsFromDictionary([
            "user": EmbeddedObjectAttribute(TrackingEventUser.self),
            "verb": EmbeddedObjectAttribute(TrackingEventVerb.self),
            "resource": EmbeddedObjectAttribute(TrackingEventResource.self),
            "timestamp": DateAttribute(),
            "result": Attribute(),
            "context": Attribute(),
            ])
    }

}
