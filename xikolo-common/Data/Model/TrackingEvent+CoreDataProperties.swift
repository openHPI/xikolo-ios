//
//  TrackingEvent+CoreDataProperties.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 16.08.17.
//  Copyright © 2017 HPI. All rights reserved.
//
//

import Foundation
import CoreData


extension TrackingEvent {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TrackingEvent> {
        return NSFetchRequest<TrackingEvent>(entityName: "TrackingEvent")
    }

    @NSManaged var id: String
    @NSManaged var user: TrackingEventUser?
    @NSManaged var verb: TrackingEventVerb?
    @NSManaged var resource: TrackingEventResource?
    @NSManaged var result: NSObject?
    @NSManaged var context: NSObject?
    @NSManaged var timestamp: NSDate?

}
