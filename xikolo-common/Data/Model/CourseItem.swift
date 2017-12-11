//
//  CourseItem.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 13.05.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import CoreData
import Foundation

final class CourseItem : NSManagedObject {

    @NSManaged var id: String
    @NSManaged var title: String?
    @NSManaged var position: Int32
    @NSManaged var visited: Bool
    @NSManaged var proctored: Bool
    @NSManaged var accessible: Bool
    @NSManaged var contentType: String?
    @NSManaged var icon: String?
    @NSManaged var exerciseType: String?
    @NSManaged var deadline: Date?
    @NSManaged private var objectStateValue: Int16

    @NSManaged var content: Content?
    @NSManaged var section: CourseSection?

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CourseItem> {
        return NSFetchRequest<CourseItem>(entityName: "CourseItem");
    }

    var next: CourseItem? {
        return self.neighbor(1)
    }

    var previous: CourseItem? {
        return self.neighbor(-1)
    }

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
        self.contentType = try attributes.value(for: "content_type")
        self.exerciseType = try attributes.value(for: "exercise_type")
        self.proctored = try attributes.value(for: "proctored")
        self.accessible = try attributes.value(for: "accessible")
        self.visited = try attributes.value(for: "visited") || self.visited  // course items can't be set to 'not visited'


        let relationships = try object.value(for: "relationships") as JSON
        try self.updateRelationship(forKeyPath: \CourseItem.section, forKey: "section", fromObject: relationships, including: includes, inContext: context)

        try self.updateAbstractRelationship(forKeyPath: \CourseItem.content, forKey: "content", fromObject: relationships, including: includes, inContext: context) { container in
            try container.update(forType: Video.self)
            try container.update(forType: RichText.self)
            try container.update(forType: Quiz.self)
            try container.update(forType: LTIExercise.self)
            try container.update(forType: PeerAssessment.self)
        }
    }

}

extension CourseItem : Pushable {

    var objectState: ObjectState {
        get {
            return ObjectState(rawValue: self.objectStateValue)!
        }
        set {
            self.objectStateValue = newValue.rawValue
        }
    }

    func markAsUnchanged() {
        self.objectState = .unchanged
    }

    func resourceAttributes() -> [String : Any] {
        return [ "visited": self.visited ]
    }

}
