//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation
import SyncEngine

public class ExerciseProgress: NSObject {

    public var exercisesAvailable: Int
    public var exercisesTaken: Int
    public var pointsPossible: Double
    public var pointsScored: Double

    public required init(object: JSON) throws {
        self.exercisesAvailable = try object.value(for: "exercise_available")
        self.exercisesTaken = try object.value(for: "exercise_taken")
        self.pointsPossible = try object.value(for: "points_possible")
        self.pointsScored = try object.value(for: "points_scored")
    }

    public func update(object: JSON) throws {
        self.exercisesAvailable = try object.value(for: "exercise_available")
        self.exercisesTaken = try object.value(for: "exercise_taken")
        self.pointsPossible = try object.value(for: "points_possible")
        self.pointsScored = try object.value(for: "points_scored")
    }
}
