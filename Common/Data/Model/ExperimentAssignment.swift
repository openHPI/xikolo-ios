//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import CoreData
import Stockpile

public final class ExperimentAssignment {

    let experimentIdentifier: String
    let course: Course?

    public init(experimentIdentifier: String, course: Course? = nil) {
        self.experimentIdentifier = experimentIdentifier
        self.course = course
    }

}

extension ExperimentAssignment: JSONAPIPushable {

    public static var type: String {
        return "experiment-assignments"
    }

    public var objectStateValue: Int16 {
        get {
            return ObjectState.new.rawValue
        }
        set {} // swiftlint:disable:this unused_setter_value
    }

    public func markAsUnchanged() {
        // No need to implement something here
    }

    public func resourceAttributes() -> [String: Any] {
        return [ "identifier": self.experimentIdentifier ]
    }

    public func resourceRelationships() -> [String: AnyObject]? {
        guard let course = self.course else { return nil }
        return [ "course": course as AnyObject ]
    }

}
