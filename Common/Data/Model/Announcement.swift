//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import CoreData
import Foundation
import SyncEngine

public final class Announcement: NSManagedObject {

    @NSManaged public var id: String
    @NSManaged public var title: String?
    @NSManaged public var text: String?
    @NSManaged public var publishedAt: Date?
    @NSManaged public var visited: Bool
    @NSManaged public var imageURL: URL?
    @NSManaged public var objectStateValue: Int16

    @NSManaged public var course: Course?

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Announcement> {
        return NSFetchRequest<Announcement>(entityName: "Announcement")
    }

}

extension Announcement: JSONAPIPullable {

    public static var type: String {
        return "announcements"
    }

    public func update(from object: ResourceData, with context: SynchronizationContext) throws {
        let attributes = try object.value(for: "attributes") as JSON
        self.title = try attributes.value(for: "title")
        self.text = try attributes.value(for: "text")
        self.imageURL = try attributes.failsafeURL(for: "image_url")
        self.publishedAt = try attributes.value(for: "published_at")
        self.visited = try attributes.value(for: "visited") || self.visited // announcements can't be set to 'not visited'

        if let relationships = try? object.value(for: "relationships") as JSON {
            try self.updateRelationship(forKeyPath: \Self.course, forKey: "course", fromObject: relationships, with: context)
        }
    }

}

extension Announcement: JSONAPIPushable {

    public func markAsUnchanged() {
        self.objectState = .unchanged
    }

    public func resourceAttributes() -> [String: Any] {
        return [ "visited": self.visited ]
    }

}
