//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures
import Stockpile

public enum ExperimentAssignmentHelper {

    @discardableResult
    public static func assign(to experimentIdentifier: String, inCourse course: Course? = nil) -> Future<Void, XikoloError> {
        let experimentAssignment = ExperimentAssignment(experimentIdentifier: experimentIdentifier, course: course)
        return XikoloSyncEngine().createResource(experimentAssignment)
    }

}
