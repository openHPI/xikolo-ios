//
//  CourseSection.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 04.05.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import CoreData
import Foundation

final class CourseSection : NSManagedObject {

    @NSManaged var id: String
    @NSManaged var abstract: String?
    @NSManaged var title: String?
    @NSManaged var position: Int32
    @NSManaged var accessible: Bool
    @NSManaged var startsAt: Date?
    @NSManaged var endsAt: Date?

    @NSManaged var course: Course?
    @NSManaged var items: Set<CourseItem>

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CourseSection> {
        return NSFetchRequest<CourseSection>(entityName: "CourseSection");
    }

    var itemsSorted: [CourseItem] {
        return self.items.sorted {
            return $0.position < $1.position
        }
    }

}

extension CourseSection : Pullable {

    static var type: String {
        return "course-sections"
    }

    func update(withObject object: ResourceData, including includes: [ResourceData]?, inContext context: NSManagedObjectContext) throws {
        let attributes = try object.value(for: "attributes") as JSON
        self.title = try attributes.value(for: "title")
        self.position = try attributes.value(for: "position")
        self.abstract = try attributes.value(for: "description")
        self.accessible = try attributes.value(for: "accessible")
        self.startsAt = try attributes.value(for: "start_at")
        self.endsAt = try attributes.value(for: "end_at")

        let relationships = try object.value(for: "relationships") as JSON
        try self.updateRelationship(forKeyPath: \CourseSection.course, forKey: "course", fromObject: relationships, including: includes, inContext: context)
    }
}
