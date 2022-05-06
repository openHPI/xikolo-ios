//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import UserNotifications

enum XikoloNotification {

    enum CategoryIdentifier {
        static let automatedDownloads = "XikoloAutomatedDownloadCategory"
    }

    enum ActionIdentifier {
        static let download = "XikoloDownload"
    }

    enum RequestIdentifier {
        static let automatedDownloads = "XikoloAutomatedDownloadLocalNotification"

        static func identifier(for section: CourseSection) -> String {
            return "new-content-section-\(section.id)"
        }
    }

    static func setNotificationCategories() {
        let center = UNUserNotificationCenter.current()
        #warning("TODO: localize")
        let downloadAction = UNNotificationAction(identifier: ActionIdentifier.download, title: "Download now", options: [])
        let category = UNNotificationCategory(identifier: CategoryIdentifier.automatedDownloads, actions: [downloadAction], intentIdentifiers: [])
        center.setNotificationCategories([category])
    }

    static func sectionStartNotificationRequest(for section: CourseSection) -> UNNotificationRequest? {
        guard let sectionStart = section.startsAt, sectionStart.inFuture else { return nil }

        let identifier = Self.RequestIdentifier.identifier(for: section)

        #warning("TODO: localize")
        let content = UNMutableNotificationContent()
        if let courseTitle = section.course?.title {
            content.title = "New course material available for \"\(courseTitle)\""
        } else {
            content.title = "New course material available"
        }

        content.body = "Videos can be now be downloaded"
        content.categoryIdentifier = self.CategoryIdentifier.automatedDownloads
        content.userInfo = ["section-id": section.id]

        let dateComponents = Calendar.autoupdatingCurrent.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: sectionStart
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)

        return UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
    }

}
