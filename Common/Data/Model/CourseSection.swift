//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import CoreData
import Foundation
import Stockpile

public final class CourseSection: NSManagedObject {

    @NSManaged public var id: String
    @NSManaged public var abstract: String?
    @NSManaged public var title: String?
    @NSManaged public var position: Int32
    @NSManaged public var accessible: Bool
    @NSManaged public var startsAt: Date?
    @NSManaged public var endsAt: Date?

    @NSManaged public var course: Course?
    @NSManaged public var items: Set<CourseItem>

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CourseSection> {
        return NSFetchRequest<CourseSection>(entityName: "CourseSection")
    }

    var itemsSorted: [CourseItem] {
        return self.items.sorted {
            return $0.position < $1.position
        }
    }

}

extension CourseSection: JSONAPIPullable {

    public static var type: String {
        return "course-sections"
    }

    public func update(from object: ResourceData, with context: SynchronizationContext) throws {
        let attributes = try object.value(for: "attributes") as JSON
        self.title = try attributes.value(for: "title")
        self.position = try attributes.value(for: "position")
        self.abstract = try attributes.value(for: "description")
        self.accessible = try attributes.value(for: "accessible")
        self.startsAt = try attributes.value(for: "start_at")
        self.endsAt = try attributes.value(for: "end_at")

        let relationships = try object.value(for: "relationships") as JSON
        try self.updateRelationship(forKeyPath: \Self.course, forKey: "course", fromObject: relationships, with: context)
    }
}
