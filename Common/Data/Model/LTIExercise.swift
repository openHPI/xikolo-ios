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
    @NSManaged private var exerciseTypeValue: String?
    @NSManaged public var launchURL: URL?

    public var exerciseType: ExerciseType? {
        guard let value = exerciseTypeValue else { return nil }
        return ExerciseType.init(rawValue: value)
    }

    public enum ExerciseType : String {
        case main = "main"
        case bonus = "bonus"
        case ungraded = "ungraded"
    }

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
        self.exerciseTypeValue = try attributes.value(for: "exercise_type")
        self.launchURL = try attributes.value(for: "launch_url")
    }

}
