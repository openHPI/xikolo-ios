//
//  CourseItem.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 13.05.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import CoreData
import Foundation
import Spine

@objcMembers
final class CourseItem : BaseModel {

    @NSManaged var id: String
    @NSManaged var title: String?
    @NSManaged var position: Int32
    @NSManaged var visited: Bool
    @NSManaged var proctored: Bool
    @NSManaged var accessible: Bool
    @NSManaged var icon: String?
    @NSManaged var exerciseType: String?
    @NSManaged var deadline: Date?

    @NSManaged var content: Content?
    @NSManaged var section: CourseSection?

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CourseItem> {
        return NSFetchRequest<CourseItem>(entityName: "CourseItem");
    }

    // TODO non-optional, computed property
    var iconName: String? {
        get {
            if let content = content {
                return content.iconName()
            }
            // TODO: better default icon
            return "homework"
        }
    }

    var next: CourseItem? {
        return self.neighbor(1)
    }

    var previous: CourseItem? {
        return self.neighbor(-1)
    }

//    var proctored: Bool {
//        get {
//            return proctored_int?.boolValue ?? false
//        }
//        set(new_is_proctored) {
//            proctored_int = new_is_proctored as NSNumber?
//        }
//    }
//
//    var accessible: Bool {
//        get {
//            return accessible_int?.boolValue ?? false
//        }
//        set(new_is_accessible) {
//            accessible_int = new_is_accessible as NSNumber?
//        }
//    }
//
//    var visited: Bool? {
//        get {
//            return visited_int?.boolValue
//        }
//        set(new_has_visited) {
//            visited_int = new_has_visited as NSNumber?
//        }
//    }

    private func neighbor(_ direction: Int) -> CourseItem? {
        let items = self.section?.itemsSorted ?? []
        if var index = items.index(of: self) {
            index += direction
            if index < 0 || index >= items.count {
                return nil
            }
            return items[index]
        }
        return nil
    }

}

extension CourseItem : Pullable {

    static var type: String {
        return "course-items"
    }

    func update(withObject object: ResourceData, including includes: [ResourceData]?, inContext context: NSManagedObjectContext) throws {
        let attributes = try object.value(for: "attributes") as JSON
        self.title = try attributes.value(for: "title")
        self.position = try attributes.value(for: "position")
        self.deadline = try attributes.value(for: "deadline")
        self.icon = try attributes.value(for: "icon")
        self.exerciseType = try attributes.value(for: "exercise_type")
        self.proctored = try attributes.value(for: "proctored")
        self.accessible = try attributes.value(for: "accessible")
        self.visited = try attributes.value(for: "visited")

        let relationships = try object.value(for: "relationships") as JSON
        try self.updateRelationship(forKeyPath: \CourseItem.section, forKey: "section", fromObject: relationships, including: includes, inContext: context)

        try self.updateAbstractRelationship(forKeyPath: \CourseItem.content, forKey: "content", fromObject: relationships, including: includes, inContext: context) { container in
            try container.update(forType: Video.self)
            try container.update(forType: RichText.self)
            try container.update(forType: Quiz.self)
            try container.update(forType: LTIExercise.self)
            try container.update(forType: PeerAssessment.self)
        }
//        try self.updateRelationship(forKeyPath: \CourseItem.content, forKey: "content", withType: Video.self, fromObject: relationships, including: includes, inContext: context)
//        try self.updateRelationship(forKeyPath: \CourseItem.content, forKey: "content", withType: RichText.self, fromObject: relationships, including: includes, inContext: context)
//        try self.updateRelationship(forKeyPath: \CourseItem.content, forKey: "content", withType: Quiz.self, fromObject: relationships, including: includes, inContext: context)
//        try self.updateRelationship(forKeyPath: \CourseItem.content, forKey: "content", withType: PeerAssessment.self, fromObject: relationships, including: includes, inContext: context)
//        try self.updateRelationship(forKeyPath: \CourseItem.content, forKey: "content", withType: LTIExercise.self, fromObject: relationships, including: includes, inContext: context)
    }

}

//@objcMembers
//class CourseItemSpine : BaseModelSpine {
//
//    var title: String?
//    var visited_int: NSNumber?
//    var proctored_int: NSNumber?
//    var position: NSNumber? // Must be NSNumber, because Int? is not KVC compliant.
//    var accessible_int: NSNumber?
//    var icon: String?
//    var exercise_type: String?
//    var deadline: Date?
//
//    var content: BaseModelSpine?
//
//    //used for PATCH
//    convenience init(courseItem: CourseItem){
//        self.init()
//        self.id = courseItem.id
//        self.visited_int = courseItem.visited_int
//        //TODO: What about content
//    }
//
//    override class var cdType: BaseModel.Type {
//        return CourseItem.self
//    }
//
//    override class var resourceType: ResourceType {
//        return "course-items"
//    }
//
//    override class var fields: [Field] {
//        return fieldsFromDictionary([
//            "title": Attribute(),
//            "content": ToOneRelationship(ContentSpine.self),
//            "visited_int": BooleanAttribute().serializeAs("visited"),
//            "proctored_int": BooleanAttribute().serializeAs("proctored"),
//            "position": Attribute(),
//            "accessible_int": BooleanAttribute().serializeAs("accessible"),
//            "icon": Attribute(),
//            "exercise_type": Attribute(),
//            "deadline": DateAttribute(),
//        ])
//    }
//
//}

