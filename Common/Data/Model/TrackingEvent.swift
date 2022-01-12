//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import CoreData
import Stockpile

public final class TrackingEvent: NSManagedObject {

    @NSManaged var user: TrackingEventUser
    @NSManaged var verb: TrackingEventVerb
    @NSManaged var resource: TrackingEventResource
    @NSManaged var timestamp: Date
    @NSManaged var timeZoneIdentifier: String
    @NSManaged var result: [String: AnyObject]?
    @NSManaged var context: [String: AnyObject]?

    @discardableResult convenience init(user: TrackingEventUser,
                                        verb: TrackingEventVerb,
                                        resource: TrackingEventResource,
                                        result: [String: AnyObject] = [:],
                                        trackingContext: [String: AnyObject] = [:],
                                        inContext context: NSManagedObjectContext) {
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

extension TrackingEvent: JSONAPIPushable {

    public static var type: String {
        return "tracking-events"
    }

    public var objectStateValue: Int16 {
        get {
            return ObjectState.new.rawValue
        }
        set {} // swiftlint:disable:this unused_setter_value
    }

    public func markAsUnchanged() {
        // No need to implement something here
    }

    public func resourceAttributes() -> [String: Any] {
        let dateFormatOptions: ISO8601DateFormatter.Options
        if #available(iOS 11.2, *) {
            // Yes, .withFractionalSeconds is available since iOS 11.0 but this will crash on iOS 11.1
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
            "result": (self.result ?? [:]) as Any,
            "context": (self.context ?? [:]) as Any,
        ]
    }

}
