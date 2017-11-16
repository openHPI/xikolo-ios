//
//  LTIExercise.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 20.08.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import CoreData
import Foundation
import Spine

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

//@objcMembers
//class LTIExerciseSpine : ContentSpine {
//
//    var instructions: String?
//    var weight: NSNumber?
//    var allowed_attempts: NSNumber?
//    var lock_submissions_at: Date?
//
//    override class var cdType: BaseModel.Type {
//        return LTIExercise.self
//    }
//
//    override class var resourceType: ResourceType {
//        return "lti-exercises"
//    }
//
//    override class var fields: [Field] {
//        return fieldsFromDictionary([
//            "instructions": Attribute(),
//            "weight": Attribute(),
//            "allowed_attempts": Attribute(),
//            "lock_submissions_at": DateAttribute(),
//        ])
//    }
//
//}

