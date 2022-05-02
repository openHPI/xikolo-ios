//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

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
    }

    static func setNotificationCategories() {
        let center = UNUserNotificationCenter.current()
        let downloadAction = UNNotificationAction(identifier: ActionIdentifier.download, title: "Download now", options: []) // TODO: localized
        let category = UNNotificationCategory(identifier: CategoryIdentifier.automatedDownloads, actions: [downloadAction], intentIdentifiers: [])
        center.setNotificationCategories([category])
    }

    static var automatedDownloadsNotificationRequest: UNNotificationRequest { // TODO: localize
        let identifier = XikoloNotification.RequestIdentifier.automatedDownloads

        let content = UNMutableNotificationContent()
        content.title = "New course material available"
        content.body = "Download videos now"
        content.categoryIdentifier = self.CategoryIdentifier.automatedDownloads

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)

        return UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
    }

}
