//
//  TrackingEvent.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 29.08.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import Foundation
import Spine

class TrackingEvent : Resource {

    var user: TrackingEventUser?
    var verb: TrackingEventVerb?
    var resource: TrackingEventResource?
    var timestamp: NSDate?
    var result: [String: AnyObject]?
    var context: [String: AnyObject]?

    override class var resourceType: ResourceType {
        return "tracking-events"
    }

    override class var fields: [Field] {
        return fieldsFromDictionary([
            "user": EmbeddedObjectAttribute(TrackingEventUser),
            "verb": EmbeddedObjectAttribute(TrackingEventVerb),
            "resource": EmbeddedObjectAttribute(TrackingEventResource),
            "timestamp": DateAttribute(),
            "result": Attribute(),
            "context": Attribute(),
        ])
    }

}
