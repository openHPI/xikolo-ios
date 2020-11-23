//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import UserNotifications

@available(iOS 13, *)
class XikoloNotificationDelegate: NSObject, UNUserNotificationCenterDelegate {

//    func userNotificationCenter(_ center: UNUserNotificationCenter,
//                                willPresent notification: UNNotification,
//                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
//        // Show alert to the user
//        completionHandler([.alert])
//    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        // Determine the user action
        switch response.actionIdentifier {
        case UNNotificationDefaultActionIdentifier:
            print("Default")
            // open course
        case "UYLDownload":
            AutomatedDownloadsManager.downloadNewContent()
            // start download
        default:
            print("Unknown action")
            //nothing
        }
        completionHandler()
    }

}
