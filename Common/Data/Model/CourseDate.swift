//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import CoreData

public final class CourseDate: NSManagedObject {

    @NSManaged public var id: String
    @NSManaged public var title: String?
    @NSManaged public var type: String?
    @NSManaged public var date: Date?
    @NSManaged public var course: Course?

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CourseDate> {
        return NSFetchRequest<CourseDate>(entityName: "CourseDate")
    }

}

extension CourseDate: Pullable {

    public static var type: String {
        return "course-dates"
    }

    func update(withObject object: ResourceData, including includes: [ResourceData]?, inContext context: NSManagedObjectContext) throws {
        let attributes = try object.value(for: "attributes") as JSON
        self.title = try attributes.value(for: "title")
        self.type = try attributes.value(for: "type")
        self.date = try attributes.value(for: "date")

        let relationships = try object.value(for: "relationships") as JSON
        try self.updateRelationship(forKeyPath: \CourseDate.course, forKey: "course", fromObject: relationships, including: includes, inContext: context)
    }

}
