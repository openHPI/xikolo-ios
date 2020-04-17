//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import UIKit

@available(iOS 13.0, *)
class OpenCourseSceneDelegate: UIResponder, UIWindowSceneDelegate {

    private lazy var courseViewController: CourseViewController = {
        let courseViewController = CourseViewController.init()

        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains("-forceDarkMode") {
            courseViewController.overrideUserInterfaceStyle = .dark
        }
        #endif

        return courseViewController
    }()

    var window: UIWindow?

    private var shortcutItemToProcess: UIApplicationShortcutItem?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        if let windowScene = scene as? UIWindowScene {
            self.window = UIWindow(windowScene: windowScene)
            self.window?.rootViewController = self.courseViewController // XXX: Set course vc here
            self.window?.tintColor = Brand.default.colors.window
            self.window?.makeKeyAndVisible()
        }
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        shortcutItemToProcess = nil
    }

    func sceneWillResignActive(_ scene: UIScene) {
        AppDelegate.instance().setHomescreenQuickActions()
    }

    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
    }

    func stateRestorationActivity(for scene: UIScene) -> NSUserActivity? {
        return scene.userActivity
    }

}
