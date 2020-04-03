//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation
import Stockpile

public class ExerciseProgress: NSObject, NSCoding, IncludedPullable {

    public var exercisesAvailable: Int?
    public var exercisesTaken: Int?
    public var pointsPossible: Double?
    public var pointsScored: Double?

    public var hasProgress: Bool {
        return !(self.pointsPossible?.isZero ?? true)
    }

    public var percentage: Double? {
        guard let scored = self.pointsScored else { return nil }
        guard let possible = self.pointsPossible, !possible.isZero else { return nil }
        return Double(scored) / Double(possible)
    }

    public required init(object: ResourceData) throws {
        self.exercisesAvailable = try object.value(for: "exercise_available")
        self.exercisesTaken = try object.value(for: "exercise_taken")
        self.pointsPossible = try object.value(for: "points_possible")
        self.pointsScored = try object.value(for: "points_scored")
    }

    public required init(coder decoder: NSCoder) {
        self.exercisesAvailable = decoder.decodeObject(forKey: "exercise_available") as? Int
        self.exercisesTaken = decoder.decodeObject(forKey: "exercise_taken") as? Int
        self.pointsPossible = decoder.decodeObject(forKey: "points_possible") as? Double
        self.pointsScored = decoder.decodeObject(forKey: "points_scored") as? Double
}

    public func encode(with coder: NSCoder) {
        coder.encode(self.exercisesAvailable, forKey: "exercise_available")
        coder.encode(self.exercisesTaken, forKey: "exercise_taken")
        coder.encode(self.pointsPossible, forKey: "points_possible")
        coder.encode(self.pointsScored, forKey: "points_scored")
    }

}
