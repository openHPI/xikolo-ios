//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures
import CoreData
import Foundation
import SyncEngine

public final class CourseProgress: NSManagedObject {

    @NSManaged public var id: String

    @NSManaged public var mainProgress: ExerciseProgress
    @NSManaged public var selftestProgress: ExerciseProgress
    @NSManaged public var bonusProgress: ExerciseProgress
    @NSManaged public var visitPrograss: Visits

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CourseProgress> {
        return NSFetchRequest<CourseProgress>(entityName: "CourseProgress")
    }
}

extension CourseProgress: JSONAPIPullable {

    public static var type: String {
        return "course-progress"
    }

    public func update(from object: ResourceData, with context: SynchronizationContext) throws {
        let data = try object.value(for: "data") as JSON
        let attributes = try data.value(for: "attributes") as JSON

        let mainExercise = try attributes.value(for: "main_exercise") as JSON
        try mainProgress.update(object: mainExercise)

        let selftestExercise = try attributes.value(for: "selftest_exercises") as JSON
        try selftestProgress.update(object: selftestExercise)

        let bonusExercise = try attributes.value(for: "bonus_exercises") as JSON
        try bonusProgress.update(object: bonusExercise)

        let visits = try attributes.value(for: "visits") as JSON
        try visitPrograss.update(object: visits)
    }
}
