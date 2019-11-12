//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures
import SyncEngine

public enum HelpdeskTicketHelper {

    @discardableResult static func createIssue(_ ticket: HelpdeskTicket) -> Future<Void, XikoloError> {
        return XikoloSyncEngine().createResource(ticket)
    }

    public static func validate(title: String?, email: String?, report: String?, typeIndex: Int?, courseIndex: Int?, numberOfSegments: Int) -> Bool {
        let issueTitleGiven = !(title?.isEmpty ?? true)
        let mailAddressGiven = !(email?.isEmpty ?? true)
        let issueReportGiven = !(report?.isEmpty ?? true)
        let notCourseSpecificTopic = typeIndex != numberOfSegments - 1
        let courseSelected = courseIndex != 0
        return (notCourseSpecificTopic || courseSelected) && mailAddressGiven && issueReportGiven && issueTitleGiven ? true : false
    }

}
