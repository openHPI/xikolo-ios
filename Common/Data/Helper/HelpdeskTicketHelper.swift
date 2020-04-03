//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures
import Stockpile

public enum HelpdeskTicketHelper {

    @discardableResult public static func createIssue(_ ticket: HelpdeskTicket) -> Future<Void, XikoloError> {
        return XikoloSyncEngine().createResource(ticket)
    }

}
