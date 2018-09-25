//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import CoreData
import SyncEngine

public final class UserProfile: NSManagedObject {

    @NSManaged public var id: String
    @NSManaged public var displayName: String?
    @NSManaged public var firstName: String?
    @NSManaged public var lastName: String?
    @NSManaged public var email: String?
    @NSManaged public var user: User?

    public var fullName: String? {
        let components = [self.firstName, self.lastName].compactMap { $0 }
        return components.isEmpty ? nil : components.joined(separator: " ")
    }

}

extension UserProfile: Pullable {

    public static var type: String {
        return "user-profile"
    }

    public func update(from object: ResourceData, with context: SynchronizationContext) throws {
        let attributes = try object.value(for: "attributes") as JSON
        self.displayName = try attributes.value(for: "display_name")
        self.firstName = try attributes.value(for: "first_name")
        self.lastName = try attributes.value(for: "last_name")
        self.email = try attributes.value(for: "email")
    }

}
