//
//  CourseSection.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 04.05.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import CoreData
import Foundation
import Spine

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
//        guard let courseItems = self.items?.allObjects as? [CourseItem] else {
//            return []
//        }

        return self.items.sorted {
//            guard let firstPosition = $0.position, let secondPosition = $1.position else {
//                return false
//            }
            return $0.position < $1.position
        }
    }

//    var accessible: Bool {
//        get {
//            return accessible_int?.boolValue ?? false
//        }
//        set(new_is_accessible) {
//            accessible_int = new_is_accessible as NSNumber?
//        }
//    }

    var sectionName: String? {
        return self.title
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
//        try self.updateRelationship(forKeyPath: \CourseSection.items, forKey: "items", fromObject: relationships, including: includes, inContext: context)
    }
}

//@objcMembers
//class CourseSectionSpine : BaseModelSpine {
//
//    var title: String?
//    var section_description: String?
//    var position: NSNumber? // Must be NSNumber, because Int? is not KVC compliant.
//    var start_at: Date?
//    var end_at: Date?
//    var accessible_int: NSNumber?
//
//    override class var cdType: BaseModel.Type {
//        return CourseSection.self
//    }
//
//    override class var resourceType: ResourceType {
//        return "course-sections"
//    }
//
//    override class var fields: [Field] {
//        return fieldsFromDictionary([
//            "title": Attribute(),
//            "section_description": Attribute().serializeAs("description"),
//            "position": Attribute(),
//            "start_at": DateAttribute(),
//            "end_at": DateAttribute(),
//            "accessible_int": BooleanAttribute().serializeAs("accessible"),
//        ])
//    }
//
//}

