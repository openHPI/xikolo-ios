//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import CoreData
import Foundation
import SyncEngine

final public class LTIExercise: Content {

    @NSManaged public var id: String
    @NSManaged public var instructions: String?
    @NSManaged public var weight: Int32
    @NSManaged public var allowedAttempts: Int32
    @NSManaged public var lockSubmissionsAt: Date?

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LTIExercise> {
        return NSFetchRequest<LTIExercise>(entityName: "LTIExercise")
    }

}

extension LTIExercise: JSONAPIPullable {

    public static var type: String {
        return "lti-exercises"
    }

    public func update(from object: ResourceData, with context: SynchronizationContext) throws {
        let attributes = try object.value(for: "attributes") as JSON
        self.instructions = try attributes.value(for: "instructions")
        self.weight = try attributes.value(for: "weight")
        self.allowedAttempts = try attributes.value(for: "allowed_attempts")
        self.lockSubmissionsAt = try attributes.value(for: "lock_submissions_at")
    }

}
