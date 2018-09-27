//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import CoreData
import SyncEngine

final class PlatformEvent: NSManagedObject {

    @NSManaged var id: String
    @NSManaged var createdAt: Date?
    @NSManaged var preview: String?
    @NSManaged var title: String?
    @NSManaged var type: String?
    @NSManaged var course: Course?

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PlatformEvent> {
        return NSFetchRequest<PlatformEvent>(entityName: "PlatformEvent")
    }

}

extension PlatformEvent: JSONAPIPullable {

    static var type: String {
        return "platform-events"
    }

    public func update(from object: ResourceData, with context: SynchronizationContext) throws {
        let attributes = try object.value(for: "attributes") as JSON
        self.title = try attributes.value(for: "title")
        self.createdAt = try attributes.value(for: "created_at")
        self.preview = try attributes.value(for: "preview")
        self.type = try attributes.value(for: "type")

        let relationships = try object.value(for: "relationships") as JSON
        try self.updateRelationship(forKeyPath: \PlatformEvent.course, forKey: "course", fromObject: relationships, with: context)
    }

}
