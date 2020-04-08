//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import CoreData
import Stockpile

public final class UserProfile: NSManagedObject {

    @NSManaged public var id: String
    @NSManaged public var fullName: String?
    @NSManaged public var email: String?
    @NSManaged public var user: User?

}

extension UserProfile: JSONAPIPullable {

    public static var type: String {
        return "user-profile"
    }

    public func update(from object: ResourceData, with context: SynchronizationContext) throws {
        let attributes = try object.value(for: "attributes") as JSON
        self.fullName = try attributes.value(for: "full_name")
        self.email = try attributes.value(for: "email")
    }

}
