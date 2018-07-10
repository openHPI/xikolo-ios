//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import CoreData

public final class User: NSManagedObject {

    @NSManaged public var id: String
    @NSManaged public var name: String?
    @NSManaged public var avatarURL: URL?
    @NSManaged public var profile: UserProfile?

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

}

extension User: Pullable {

    public static var type: String {
        return "users"
    }

    func update(withObject object: ResourceData, including includes: [ResourceData]?, inContext context: NSManagedObjectContext) throws {
        let attributes = try object.value(for: "attributes") as JSON
        self.name = try attributes.value(for: "name")
        self.avatarURL = try attributes.value(for: "avatar_url")

        let relationships = try object.value(for: "relationships") as JSON
        try self.updateRelationship(forKeyPath: \User.profile, forKey: "profile", fromObject: relationships, including: includes, inContext: context)
    }

}
