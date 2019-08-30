//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import UIKit

@available(iOS 13.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    private var tabBarController: UITabBarController? {
        guard let tabBarController = self.window?.rootViewController as? UITabBarController else {
            let reason = "UITabBarController could not be found"
            ErrorManager.shared.reportStoryboardError(reason: reason)
            log.error(reason)
            return nil
        }

        return tabBarController
    }

    lazy var appNavigator = AppNavigator(tabBarController: self.tabBarController!)

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        #if DEBUG
        log.info("Entered scene willConnectTo session")
        #endif

        self.window?.tintColor = Brand.default.colors.window

        self.tabBarController?.selectedIndex = UserProfileHelper.shared.isLoggedIn ? 0 : 1
        if UserProfileHelper.shared.isLoggedIn {
            CourseHelper.syncAllCourses().onComplete { _ in
                CourseDateHelper.syncAllCourseDates()
            }
        }

        // register tab bar delegate
        self.tabBarController?.delegate = self

        TrackingHelper.shared.delegate = self
        AnnouncementHelper.shared.delegate = self

        if (connectionOptions.userActivities.first ?? session.stateRestorationActivity) != nil {
            log.info("Entered positive if clause")

        }
        #if DEBUG
        log.info("Exiting scene willConnectTo session")
        #endif
    }

    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        self.appNavigator.handle(userActivity: userActivity)
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        self.appNavigator.handle(url: url)
    }

    func stateRestorationActivity(for scene: UIScene) -> NSUserActivity? {
        log.info("Trying to return userActivity")
        return scene.userActivity
    }
}

@available(iOS 13.0, *)
extension SceneDelegate: UITabBarControllerDelegate {

    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        guard !UserProfileHelper.shared.isLoggedIn else {
            return true
        }

        guard let navigationController = viewController as? UINavigationController else {
            log.info("Navigation controller not found")
            return true
        }

        guard navigationController.viewControllers.first is DashboardViewController else {
            return true
        }

        guard let loginNavigationController = R.storyboard.login.instantiateInitialViewController() else {
            let reason = "Initial view controller of Login stroyboard in not of type UINavigationController"
            ErrorManager.shared.reportStoryboardError(reason: reason)
            log.error(reason)
            return false
        }

        guard let loginViewController = loginNavigationController.viewControllers.first as? LoginViewController else {
            let reason = "Could not find LoginViewController"
            ErrorManager.shared.reportStoryboardError(reason: reason)
            log.error(reason)
            return false
        }

        loginViewController.delegate = self as LoginDelegate

        tabBarController.present(loginNavigationController, animated: trueUnlessReduceMotionEnabled)

        return false
    }

    func switchToCourseListTab() -> Bool {
        guard let tabBarController = self.tabBarController else { return false }
        tabBarController.selectedIndex = 1
        return true
    }

}

@available(iOS 13.0, *)
extension SceneDelegate: LoginDelegate {

    func didSuccessfullyLogin() {
        self.tabBarController?.selectedIndex = 0
    }

}

@available(iOS 13.0, *)
extension SceneDelegate: AnnouncementHelperDelegate {

    func updateUnreadAnnouncementsBadge() {
        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains("-cleanTabBar") {
            log.info("Don't show badge when making screenshots")
            return
        }
        #endif

        DispatchQueue.main.async {
            guard let tabItem = self.tabBarController?.tabBar.items?[safe: 2] else {
                log.warning("Failed to retrieve tab item for announcements")
                return
            }

            guard UserProfileHelper.shared.isLoggedIn else {
                tabItem.badgeValue = nil
                return
            }

            CoreDataHelper.persistentContainer.performBackgroundTask { context in
                let fetchRequest = AnnouncementHelper.FetchRequest.unreadAnnouncements
                do {
                    let announcementCount = try context.count(for: fetchRequest)
                    let badgeValue = announcementCount > 0 ? String(describing: announcementCount) : nil
                    DispatchQueue.main.async {
                        tabItem.badgeValue = badgeValue
                    }
                } catch {
                    log.warning("Failed to retrieve unread announcement count")
                }
            }
        }
    }

}

@available(iOS 13.0, *)
extension SceneDelegate: TrackingHelperDelegate {

    var applicationWindowSize: CGSize? {
        return self.window?.frame.size
    }

}
