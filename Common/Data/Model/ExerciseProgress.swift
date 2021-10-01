//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import Foundation
import Stockpile

public class ExerciseProgress: NSObject, NSSecureCoding, IncludedPullable {

    public static var supportsSecureCoding: Bool { return true }

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
        self.exercisesAvailable = decoder.decodeObject(of: NSNumber.self, forKey: "exercise_available")?.intValue
        self.exercisesTaken = decoder.decodeObject(of: NSNumber.self, forKey: "exercise_taken")?.intValue
        self.pointsPossible = decoder.decodeObject(of: NSNumber.self, forKey: "points_possible")?.doubleValue
        self.pointsScored = decoder.decodeObject(of: NSNumber.self, forKey: "points_scored")?.doubleValue
}

    public func encode(with coder: NSCoder) {
        coder.encode(self.exercisesAvailable.map(NSNumber.init(value:)), forKey: "exercise_available")
        coder.encode(self.exercisesTaken.map(NSNumber.init(value:)), forKey: "exercise_taken")
        coder.encode(self.pointsPossible.map(NSNumber.init(value:)), forKey: "points_possible")
        coder.encode(self.pointsScored.map(NSNumber.init(value:)), forKey: "points_scored")
    }

}
