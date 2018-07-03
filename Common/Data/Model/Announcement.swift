//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import CoreData
import Foundation

public final class Announcement: NSManagedObject {

    @NSManaged public var id: String
    @NSManaged public var title: String?
    @NSManaged public var text: String?
    @NSManaged public var publishedAt: Date?
    @NSManaged public var visited: Bool
    @NSManaged public var imageURL: URL?
    @NSManaged private var objectStateValue: Int16

    @NSManaged public var course: Course?

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Announcement> {
        return NSFetchRequest<Announcement>(entityName: "Announcement")
    }

}

extension Announcement: Pullable {

    public static var type: String {
        return "announcements"
    }

    func update(withObject object: ResourceData, including includes: [ResourceData]?, inContext context: NSManagedObjectContext) throws {
        let attributes = try object.value(for: "attributes") as JSON
        self.title = try attributes.value(for: "title")
        self.text = try attributes.value(for: "text")
        self.imageURL = try attributes.value(for: "image_url")
        self.publishedAt = try attributes.value(for: "published_at")
        self.visited = try attributes.value(for: "visited") || self.visited // announcements can't be set to 'not visited'

        if let relationships = try? object.value(for: "relationships") as JSON {
            try self.updateRelationship(forKeyPath: \Announcement.course, forKey: "course", fromObject: relationships, including: includes, inContext: context)
        }
    }

}

extension Announcement: Pushable {

    var objectState: ObjectState {
        get {
            return ObjectState(rawValue: self.objectStateValue).require(hint: "No object state for announcement")
        }
        set {
            self.objectStateValue = newValue.rawValue
        }
    }

    func markAsUnchanged() {
        self.objectState = .unchanged
    }

    func resourceAttributes() -> [String: Any] {
        return [ "visited": self.visited ]
    }

}
