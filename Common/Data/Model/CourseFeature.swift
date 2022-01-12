//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import CoreData
import Stockpile

public final class CourseFeature: NSManagedObject {

    @NSManaged public var id: String
    @NSManaged public var features: [String]

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CourseFeature> {
        return NSFetchRequest<CourseFeature>(entityName: "CourseFeature")
    }

}

extension CourseFeature: JSONAPIPullable {

    public static var type: String {
        return "course-features"
    }

    public func update(from object: ResourceData, with context: SynchronizationContext) throws {
        let attributes = try object.value(for: "attributes") as JSON
        self.features = try attributes.value(for: "features")
    }

}
