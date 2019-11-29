//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import UIKit

@available(iOS 13.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    private lazy var tabBarController: UITabBarController = {
        let tabBarController = XikoloTabBarController.make()
        tabBarController.delegate = self

        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains("-forceDarkMode") {
            tabBarController.overrideUserInterfaceStyle = .dark
        }
        #endif

        return tabBarController
    }()

    lazy var appNavigator = AppNavigator(tabBarController: self.tabBarController)

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        if let windowScene = scene as? UIWindowScene {
            self.window = UIWindow(windowScene: windowScene)
            self.window?.rootViewController = self.tabBarController
            self.window?.tintColor = Brand.default.colors.window
            self.window?.makeKeyAndVisible()
        }

        // Select initial tab
        let tabToSelect: XikoloTabBarController.Tabs = UserProfileHelper.shared.isLoggedIn ? .dashboard : .courses
        self.tabBarController.selectedIndex = tabToSelect.index
    }

    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        self.appNavigator.handle(userActivity: userActivity)
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        self.appNavigator.handle(url: url)
    }

    func stateRestorationActivity(for scene: UIScene) -> NSUserActivity? {
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

}

@available(iOS 13.0, *)
extension SceneDelegate: LoginDelegate {

    func didSuccessfullyLogin() {
        self.tabBarController.selectedIndex = 0
    }

}
