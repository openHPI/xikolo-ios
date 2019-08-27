//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import CoreData
import SyncEngine

public final class User: NSManagedObject {

    @NSManaged public var id: String
    @NSManaged public var name: String?
    @NSManaged public var avatarURL: URL?
    @NSManaged public var profile: UserProfile?

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

}

extension User: JSONAPIPullable {

    public static var type: String {
        return "users"
    }

    public func update(from object: ResourceData, with context: SynchronizationContext) throws {
        let attributes = try object.value(for: "attributes") as JSON
        self.name = try attributes.value(for: "name")
        
        let avatarURLString = try attributes.value(for: "avatar_url") as String
        self.avatarURL = URL(string: avatarURLString.trimmingCharacters(in: .whitespacesAndNewlines))

        let relationships = try object.value(for: "relationships") as JSON
        try self.updateRelationship(forKeyPath: \User.profile, forKey: "profile", fromObject: relationships, with: context)
    }

}
