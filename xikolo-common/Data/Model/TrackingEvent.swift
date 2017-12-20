//
//  TrackingEvent.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 29.08.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import Foundation
import CoreData

final class TrackingEvent : NSManagedObject {

    @NSManaged var user: TrackingEventUser
    @NSManaged var verb: TrackingEventVerb
    @NSManaged var resource: TrackingEventResource
    @NSManaged var timestamp: Date
    @NSManaged var timeZoneIdentifier: String
    @NSManaged var result: [String: AnyObject]?
    @NSManaged var context: [String: AnyObject]?

    convenience init(user: TrackingEventUser, verb: TrackingEventVerb, resource: TrackingEventResource, result: [String: AnyObject]? = nil, trackingContext: [String: AnyObject]? = nil, inContext context: NSManagedObjectContext) {
        self.init(context: context)
        self.user = user
        self.verb = verb
        self.resource = resource
        self.timestamp = Date()
        self.timeZoneIdentifier = TimeZone.current.identifier
        self.result = result
        self.context = trackingContext
    }

}

extension TrackingEvent : Pushable {

    static var type: String {
        return "tracking-events"
    }

    var deleteAfterSync: Bool {
        return true
    }

    var objectState: ObjectState {
        return .new
    }

    func markAsUnchanged() {
        // No need to implement something here
    }

    func resourceAttributes() -> [String : Any] {
        let dateFormatOptions: ISO8601DateFormatter.Options
        if #available(iOS 11.0, *) {
            dateFormatOptions = [.withInternetDateTime, .withFractionalSeconds]
        } else {
            dateFormatOptions = [.withInternetDateTime]
        }

        var timestamp: String?
        if let timeZone = TimeZone(identifier: self.timeZoneIdentifier) {
            timestamp = ISO8601DateFormatter.string(from: self.timestamp, timeZone: timeZone, formatOptions: dateFormatOptions)
        }

        return [
            "user": self.user.resourceAttributes(),
            "verb": self.verb.resourceAttributes(),
            "resource": self.resource.resourceAttributes(),
            "timestamp": timestamp as Any,
            "result": self.result as Any,
            "context": self.context as Any,
        ]
    }

}
