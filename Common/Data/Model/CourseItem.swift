//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import CoreData
import Foundation
import SyncEngine

public final class CourseItem: NSManagedObject {

    @NSManaged public var id: String
    @NSManaged public var title: String?
    @NSManaged public var position: Int32
    @NSManaged public var visited: Bool
    @NSManaged public var proctored: Bool
    @NSManaged public var accessible: Bool
    @NSManaged public var contentType: String?
    @NSManaged public var icon: String?
    @NSManaged public var exerciseType: String?
    @NSManaged public var deadline: Date?
    @NSManaged private var objectStateValue: Int16

    @NSManaged public var content: Content?
    @NSManaged public var section: CourseSection?

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CourseItem> {
        return NSFetchRequest<CourseItem>(entityName: "CourseItem")
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

extension CourseItem: Pullable {

    public static var type: String {
        return "course-items"
    }

    public func update(from object: ResourceData, with context: SynchronizationContext) throws {
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
        try self.updateRelationship(forKeyPath: \CourseItem.section,
                                    forKey: "section",
                                    fromObject: relationships,
                                    with: context)

        try self.updateAbstractRelationship(forKeyPath: \CourseItem.content,
                                            forKey: "content",
                                            fromObject: relationships,
                                            with: context) { container in
            try container.update(forType: Video.self)
            try container.update(forType: RichText.self)
            try container.update(forType: Quiz.self)
            try container.update(forType: LTIExercise.self)
            try container.update(forType: PeerAssessment.self)
        }
    }

}

extension CourseItem: Pushable {

    public var objectState: ObjectState {
        get {
            return ObjectState(rawValue: self.objectStateValue).require(hint: "No object state for course item")
        }
        set {
            self.objectStateValue = newValue.rawValue
        }
    }

    public func markAsUnchanged() {
        self.objectState = .unchanged
    }

    public func resourceAttributes() -> [String: Any] {
        return ["visited": self.visited]
    }

}
