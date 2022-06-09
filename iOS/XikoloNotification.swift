//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import Common
import UIKit
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
        let title = NSString.localizedUserNotificationString(forKey: "notification.new-content.action.download", arguments: nil)
        let downloadAction = UNNotificationAction(identifier: ActionIdentifier.download, title: title, options: [])
        let category = UNNotificationCategory(identifier: CategoryIdentifier.automatedDownloads, actions: [downloadAction], intentIdentifiers: [])
        center.setNotificationCategories([category])
    }

    static func sectionStartNotificationRequest(for section: CourseSection) -> UNNotificationRequest? {
        guard let sectionStart = section.startsAt, sectionStart.inFuture else { return nil }

        let identifier = Self.RequestIdentifier.identifier(for: section)

        let content = UNMutableNotificationContent()
        content.title = section.course?.title ?? UIApplication.appName
        let sectionTitle = section.title ?? String(section.position)
        content.body = NSString.localizedUserNotificationString(forKey: "notification.new-content.body", arguments: [sectionTitle])
        content.categoryIdentifier = self.CategoryIdentifier.automatedDownloads
        content.userInfo = ["section-id": section.id]

        let dateComponents = Calendar.autoupdatingCurrent.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: sectionStart.addingTimeInterval(2 * 60) // 2 minutes after section start
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)

        return UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
    }

}
