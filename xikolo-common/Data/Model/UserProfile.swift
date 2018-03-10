//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation
import CoreData

final class UserProfile: NSManagedObject {

    @NSManaged var id: String
    @NSManaged var displayName: String?
    @NSManaged var firstName: String?
    @NSManaged var lastName: String?
    @NSManaged var email: String?
    @NSManaged var user: User?

    var fullName: String? {
        let components = [self.firstName, self.lastName].flatMap{ $0 }
        return components.count > 0 ? components.joined(separator: " ") : nil
    }

}

extension UserProfile : Pullable {

    static var type: String {
        return "user-profile"
    }

    func update(withObject object: ResourceData, including includes: [ResourceData]?, inContext context: NSManagedObjectContext) throws {
        let attributes = try object.value(for: "attributes") as JSON
        self.displayName = try attributes.value(for: "display_name")
        self.firstName = try attributes.value(for: "first_name")
        self.lastName = try attributes.value(for: "last_name")
        self.email = try attributes.value(for: "email")
    }

}
