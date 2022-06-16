//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures
import Stockpile

public enum ExperimentAssignmentHelper {

    public enum ExperimentIdentifier: String {
        case newContentNotifications = "mobile.new_content_notification"
    }

    @discardableResult
    public static func assign(to experimentIdentifier: ExperimentIdentifier, inCourse course: Course? = nil) -> Future<Void, XikoloError> {
        let experimentAssignment = ExperimentAssignment(experimentIdentifier: experimentIdentifier.rawValue, course: course)
        return XikoloSyncEngine().createResource(experimentAssignment)
    }

}
