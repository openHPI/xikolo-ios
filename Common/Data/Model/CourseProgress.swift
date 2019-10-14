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
    @NSManaged public var mainExercisesAvailable: Int
    @NSManaged public var mainExercisesTaken: Int
    @NSManaged public var mainPointsPossible: Float
    @NSManaged public var mainPointsScored: Float
    @NSManaged public var selftestExercisesAvailable: Int
    @NSManaged public var selftestExercisesTaken: Int
    @NSManaged public var selftestPointsPossible: Float
    @NSManaged public var selftestPointsScored: Float
    @NSManaged public var bonusExercisesAvailable: Int
    @NSManaged public var bonusExercisesTaken: Int
    @NSManaged public var bonusPointsPossible: Float
    @NSManaged public var bonusPointsScored: Float
    @NSManaged public var itemsAvailable: Int
    @NSManaged public var itemsVisited: Int
    @NSManaged public var visitsPercentage: Float

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CourseProgress> {
        return NSFetchRequest<CourseProgress>(entityName: "CourseProgress")
    }
}

extension CourseProgress: JSONAPIPullable {

    public static var type: String {
        return "course-progress"
    }

    public func update(from object: ResourceData, with context: SynchronizationContext) throws {
        let attributes = try object.value(for: "attributes") as JSON

        let mainExercise = try attributes.value(for: "main_exercise") as JSON
        self.mainExercisesAvailable = try mainExercise.value(for: "exercise_available")
        self.mainExercisesTaken = try mainExercise.value(for: "exercise_taken")
        self.mainPointsPossible = try mainExercise.value(for: "points_possible")
        self.mainPointsScored = try mainExercise.value(for: "points_scored")

        let selftestExercise = try attributes.value(for: "selftest_exercises") as JSON
        self.selftestExercisesAvailable = try selftestExercise.value(for: "exercise_available")
        self.selftestExercisesTaken = try selftestExercise.value(for: "exercise_taken")
        self.selftestPointsPossible = try selftestExercise.value(for: "points_possible")
        self.selftestPointsScored = try selftestExercise.value(for: "points_scored")

        let bonusExercise = try attributes.value(for: "bonus_exercises") as JSON
        self.bonusExercisesAvailable = try bonusExercise.value(for: "exercise_available")
        self.bonusExercisesTaken = try bonusExercise.value(for: "exercise_taken")
        self.bonusPointsPossible = try bonusExercise.value(for: "points_possible")
        self.bonusPointsScored = try bonusExercise.value(for: "points_scored")

        let visits = try attributes.value(for: "visits") as JSON
        self.itemsAvailable = try visits.value(for: "items_available")
        self.itemsVisited = try visits.value(for: "items_visited")
        self.visitsPercentage = try visits.value(for: "visits_percentage")
    }
}
