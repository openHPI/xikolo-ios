//
//  TrackingEvent.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 29.08.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import Foundation
import CoreData

class TrackingEvent : NSManagedObject {

    @NSManaged var user: TrackingEventUser?
    @NSManaged var verb: TrackingEventVerb?
    @NSManaged var resource: TrackingEventResource?
    @NSManaged var timestamp: Date?
    @NSManaged var result: [String: AnyObject]?
    @NSManaged var context: [String: AnyObject]?

//    override class var resourceType: ResourceType {
//        return "tracking-events"
//    }
//
//    override class var fields: [Field] {
//        return fieldsFromDictionary([
//            "user": EmbeddedObjectAttribute(TrackingEventUser.self),
//            "verb": EmbeddedObjectAttribute(TrackingEventVerb.self),
//            "resource": EmbeddedObjectAttribute(TrackingEventResource.self),
//            "timestamp": DateAttribute(),
//            "result": Attribute(),
//            "context": Attribute(),
//        ])
//    }

}
