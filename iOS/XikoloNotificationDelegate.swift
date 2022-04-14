//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import UIKit
import UserNotifications

@available(iOS 13, *)
class XikoloNotificationDelegate: NSObject, UNUserNotificationCenterDelegate {

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        // Determine the user action
        switch response.actionIdentifier {
        case UNNotificationDefaultActionIdentifier:
            DispatchQueue.main.async {
                let courses = AutomatedDownloadsManager.coursesWithNewContent(in: CoreDataHelper.viewContext)
                if let course = courses.last {
                    let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
                    let navigator = sceneDelegate?.appNavigator
                    navigator?.show(course: course)
                }
                completionHandler()
            }
        case XikoloNotification.ActionIdentifier.download:
            AutomatedDownloadsManager.downloadNewContent(ignoreDownloadOption: true).onComplete { _ in
                completionHandler()
            }
        default:
            completionHandler()
            break
        }
    }

}
