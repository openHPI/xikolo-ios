//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import Common
import UserNotifications

@available(iOS 13, *)
enum NewContentNotificationManager {

    static func renewNotifications(for course: Course) {
        let center = UNUserNotificationCenter.current()

        let identifiersForPendingRequests = course.sections.map(XikoloNotification.RequestIdentifier.identifier(for:))
        center.removePendingNotificationRequests(withIdentifiers: identifiersForPendingRequests)

        guard FeatureHelper.hasFeature(.newContentNotification, for: course) else { return }

        for section in course.sections {
            guard let request = XikoloNotification.sectionStartNotificationRequest(for: section) else { continue }
            center.add(request)
        }
    }

}
