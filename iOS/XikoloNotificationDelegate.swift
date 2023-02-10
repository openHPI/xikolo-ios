//
//  Created for xikolo-ios under GPL-3.0 license.
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
        switch response.notification.request.content.categoryIdentifier {
        case XikoloNotification.CategoryIdentifier.newContent:
            self.handleNewContentNotificationResponse(response, withCompletionHandler: completionHandler)
        case XikoloNotification.CategoryIdentifier.quizRecapForSection:
            self.handleSectionQuizRecapNotificationResponse(response, withCompletionHandler: completionHandler)
        case XikoloNotification.CategoryIdentifier.quizRecapForCourse:
            self.handleCourseQuizRecapNotificationResponse(response, withCompletionHandler: completionHandler)
        default:
            completionHandler()
        }
    }

    private func handleNewContentNotificationResponse(_ response: UNNotificationResponse,
                                                      withCompletionHandler completionHandler: @escaping () -> Void) {
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
                let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
                let navigator = sceneDelegate?.appNavigator
                navigator?.show(section: courseSection)
                completionHandler()
            }
        case XikoloNotification.ActionIdentifier.download:
            AutomatedDownloadsManager.downloadContent(of: courseSection, triggeredBy: .notification).onComplete { _ in
                completionHandler()
            }
        default:
            completionHandler()
        }
    }

    private func handleSectionQuizRecapNotificationResponse(_ response: UNNotificationResponse,
                                                            withCompletionHandler completionHandler: @escaping () -> Void) {
        guard let sectionId = response.notification.request.content.userInfo["section-id"] as? String else { return }
        let fetchRequest = CourseSectionHelper.FetchRequest.courseSection(withId: sectionId)
        guard let section = CoreDataHelper.viewContext.fetchSingle(fetchRequest).value, let course = section.course else {
            completionHandler()
            return
        }

        // Determine the user action
        switch response.actionIdentifier {
        case UNNotificationDefaultActionIdentifier:
            DispatchQueue.main.async {
                let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
                let navigator = sceneDelegate?.appNavigator
                navigator?.show(course: course, with: .recap)

                if #available(iOS 15, *), FeatureHelper.hasFeature(.quizRecapVersion2, for: course) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                        let configuration = QuizRecapConfiguration(courseId: course.id,
                                                                   sectionIds: [sectionId],
                                                                   onlyVisitedItems: false,
                                                                   questionLimit: nil)
                        let quizRecapViewController = QuizRecapViewController(configuration: configuration)
                        let navigationController = UINavigationController(rootViewController: quizRecapViewController)
                        navigationController.modalPresentationStyle = .fullScreen
                        let topViewController = navigator?.tabBarController?.selectedViewController?.presentedViewController
                        topViewController?.present(navigationController, animated: trueUnlessReduceMotionEnabled)
                    }
                } else {
                    completionHandler()
                }
            }
        default:
            completionHandler()
        }
    }

    private func handleCourseQuizRecapNotificationResponse(_ response: UNNotificationResponse,
                                                           withCompletionHandler completionHandler: @escaping () -> Void) {
        guard let courseId = response.notification.request.content.userInfo["course-id"] as? String else { return }
        let fetchRequest = CourseHelper.FetchRequest.course(withSlugOrId: courseId)
        guard let course = CoreDataHelper.viewContext.fetchSingle(fetchRequest).value else {
            completionHandler()
            return
        }

        // Determine the user action
        switch response.actionIdentifier {
        case UNNotificationDefaultActionIdentifier:
            DispatchQueue.main.async {
                let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
                let navigator = sceneDelegate?.appNavigator
                navigator?.show(course: course, with: .recap)

                if #available(iOS 15, *), FeatureHelper.hasFeature(.quizRecapVersion2, for: course) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                        let configuration = QuizRecapConfiguration(courseId: course.id,
                                                                   sectionIds: Set(course.sectionsForQuizRecap.map(\.id)),
                                                                   onlyVisitedItems: false,
                                                                   questionLimit: nil)
                        let quizRecapViewController = QuizRecapViewController(configuration: configuration)
                        let navigationController = UINavigationController(rootViewController: quizRecapViewController)
                        navigationController.modalPresentationStyle = .fullScreen
                        let topViewController = navigator?.tabBarController?.selectedViewController?.presentedViewController
                        topViewController?.present(navigationController, animated: trueUnlessReduceMotionEnabled)
                    }
                } else {
                    completionHandler()
                }
            }
        default:
            completionHandler()
        }
    }

}
