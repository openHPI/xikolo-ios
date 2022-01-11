//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import Foundation
import Stockpile

public class VisitProgress: NSObject, NSSecureCoding, IncludedPullable {

    public static var supportsSecureCoding: Bool { return true }

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
        self.itemsAvailable = decoder.decodeObject(of: NSNumber.self, forKey: "items_available")?.intValue
        self.itemsVisited = decoder.decodeObject(of: NSNumber.self, forKey: "items_visited")?.intValue
        self.visitsPercentage = decoder.decodeObject(of: NSNumber.self, forKey: "visits_percentage")?.doubleValue
    }

    public func encode(with coder: NSCoder) {
        coder.encode(self.itemsAvailable.map(NSNumber.init(value:)), forKey: "items_available")
        coder.encode(self.itemsVisited.map(NSNumber.init(value:)), forKey: "items_visited")
        coder.encode(self.visitsPercentage.map(NSNumber.init(value:)), forKey: "visits_percentage")
    }

}
