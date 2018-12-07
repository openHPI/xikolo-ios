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
    @NSManaged public var maxPoints: Float
    @NSManaged public var proctored: Bool
    @NSManaged public var accessible: Bool
    @NSManaged public var contentType: String?
    @NSManaged public var icon: String?
    @NSManaged public var exerciseType: String?
    @NSManaged public var deadline: Date?
    @NSManaged public var objectStateValue: Int16

    @NSManaged public var content: Content?
    @NSManaged public var section: CourseSection?

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CourseItem> {
        return NSFetchRequest<CourseItem>(entityName: "CourseItem")
    }

    public var nextItem: CourseItem? {
        return self.neighbor(forwards: true)
    }

    public var previousItem: CourseItem? {
        return self.neighbor(forwards: false)
    }

    private func neighbor(forwards directionForwards: Bool) -> CourseItem? {
        guard let items = self.section?.itemsSorted else { return nil }
        guard let currentIndex = items.index(of: self) else { return nil }
        let nextIndex = directionForwards ? items.index(after: currentIndex) : items.index(before: currentIndex)
        return items[safe: nextIndex]
    }

}

extension CourseItem: JSONAPIPullable {

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
        self.maxPoints = try attributes.value(for: "max_points")
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

extension CourseItem: JSONAPIPushable {

    public func markAsUnchanged() {
        self.objectState = .unchanged
    }

    public func resourceAttributes() -> [String: Any] {
        return ["visited": self.visited]
    }

}
