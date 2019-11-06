//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation
import SyncEngine

public class Visits: NSObject {

    public var itemsAvailable: Int
    public var itemsVisited: Int
    public var visitsPercentage: Double

    public required init(object: JSON) throws {
        self.itemsAvailable = try object.value(for: "items_available")
        self.itemsVisited = try object.value(for: "items_visited")
        self.visitsPercentage = try object.value(for: "visits_percentage")
    }

    public func update(object: JSON) throws {
        self.itemsAvailable = try object.value(for: "items_available")
        self.itemsVisited = try object.value(for: "items_visited")
        self.visitsPercentage = try object.value(for: "visits_percentage")
    }
}
