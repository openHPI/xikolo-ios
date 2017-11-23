//
//  LTIExercise.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 20.08.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import CoreData
import Foundation

final class LTIExercise : Content {

    @NSManaged var id: String
    @NSManaged var instructions: String?
    @NSManaged var weight: Int32
    @NSManaged var allowedAttempts: Int32
    @NSManaged var lockSubmissionsAt: Date?

    override func iconName() -> String {
        return "lti_exercise"
    }

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LTIExercise> {
        return NSFetchRequest<LTIExercise>(entityName: "LTIExercise");
    }

}

extension LTIExercise : Pullable {

    static var type: String {
        return "lti-exercises"
    }

    func update(withObject object: ResourceData, including includes: [ResourceData]?, inContext context: NSManagedObjectContext) throws {
        let attributes = try object.value(for: "attributes") as JSON
        self.instructions = try attributes.value(for: "instructions")
        self.weight = try attributes.value(for: "weight")
        self.allowedAttempts = try attributes.value(for: "allowed_attempts")
        self.lockSubmissionsAt = try attributes.value(for: "lock_submissions_at")
    }

}
