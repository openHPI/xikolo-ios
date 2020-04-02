//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation
import Stockpile

public class VisitProgress: NSObject, NSCoding, IncludedPullable {

    public var itemsAvailable: Int?
    public var itemsVisited: Int?
    public var visitsPercentage: Double?

    public var percentage: Double? {
        guard let scored = itemsVisited else { return nil }
        guard let possible = itemsAvailable, possible > 0 else { return nil }
        return Double(scored) / Double(possible)
    }

    public required init(object: ResourceData) throws {
        self.itemsAvailable = try object.value(for: "items_available")
        self.itemsVisited = try object.value(for: "items_visited")
        self.visitsPercentage = try object.value(for: "visits_percentage")
    }

    public required init(coder decoder: NSCoder) {
        self.itemsAvailable = decoder.decodeObject(forKey: "items_available") as? Int
        self.itemsVisited = decoder.decodeObject(forKey: "items_visited") as? Int
        self.visitsPercentage = decoder.decodeObject(forKey: "visits_percentage") as? Double
    }

    public func encode(with coder: NSCoder) {
        coder.encode(self.itemsAvailable, forKey: "items_available")
        coder.encode(self.itemsVisited, forKey: "items_visited")
        coder.encode(self.visitsPercentage, forKey: "visits_percentage")
    }

}
