//
//  Created for xikolo-ios under GPL-3.0 license.
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

    private var themeObservation: NSKeyValueObservation?

    lazy var appNavigator = AppNavigator(tabBarController: self.tabBarController)

    var window: UIWindow?

    private var shortcutItemToProcess: UIApplicationShortcutItem?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        if let windowScene = scene as? UIWindowScene {
            self.window = UIWindow(windowScene: windowScene)
            self.window?.rootViewController = self.tabBarController
            self.window?.tintColor = Brand.default.colors.window
            self.window?.makeKeyAndVisible()
        }

        shortcutItemToProcess = connectionOptions.shortcutItem

        // Select initial tab
        let tabToSelect: XikoloTabBarController.Tabs = UserProfileHelper.shared.isLoggedIn ? .dashboard : .courses
        self.tabBarController.selectedIndex = tabToSelect.index

        self.themeObservation = UserDefaults.standard.observe(\UserDefaults.theme, options: [.initial, .new]) { [weak self] _, _ in
            self?.window?.overrideUserInterfaceStyle = UserDefaults.standard.theme.userInterfaceStyle
        }
    }

    func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        self.appNavigator.handle(shortcutItem: shortcutItem)
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        if let shortcutItem = self.shortcutItemToProcess {
            self.appNavigator.handle(shortcutItem: shortcutItem)
        }

        shortcutItemToProcess = nil
    }

    func sceneWillResignActive(_ scene: UIScene) {
        QuickActionHelper.setHomescreenQuickActions()
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
            logger.info("Navigation controller not found")
            return true
        }

        guard navigationController.viewControllers.first is DashboardViewController else {
            return true
        }

        self.appNavigator.presentDashboardLoginViewController()
        return false
    }

}
