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
        guard response.notification.request.content.categoryIdentifier == XikoloNotification.CategoryIdentifier.automatedDownloads else { return}

        guard let courseSectionId = response.notification.request.content.userInfo["section-id"] as? String else { return }
        let fetchRequest = CourseSectionHelper.FetchRequest.courseSection(withId: courseSectionId)
        guard let courseSection = CoreDataHelper.viewContext.fetchSingle(fetchRequest).value else {
            completionHandler()
            return
        }

        // Determine the user action
        switch response.actionIdentifier {
        case UNNotificationDefaultActionIdentifier:
            DispatchQueue.main.async {
                if let course = courseSection.course {
                    let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
                    let navigator = sceneDelegate?.appNavigator
                    navigator?.show(course: course, with: .learnings)
                }
                completionHandler()
            }
        case XikoloNotification.ActionIdentifier.download:
            AutomatedDownloadsManager.downloadContent(of: courseSection).onComplete { _ in
                completionHandler()
            }
        default:
            completionHandler()
            break
        }
    }

}
