//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import CoreData
import Stockpile

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
        self.avatarURL = try attributes.failsafeURL(for: "avatar_url")

        let relationships = try object.value(for: "relationships") as JSON
        try self.updateRelationship(forKeyPath: \Self.profile, forKey: "profile", fromObject: relationships, with: context)
    }

}
