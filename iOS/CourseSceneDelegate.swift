//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import UIKit

@available(iOS 13.0, *)
class CourseSceneDelegate: UIResponder, UIWindowSceneDelegate {

    private lazy var courseNavigationController: CourseNavigationController = {
        let courseNavigationController = R.storyboard.course.instantiateInitialViewController().require()

        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains("-forceDarkMode") {
            courseNavigationController.overrideUserInterfaceStyle = .dark
        }
        #endif

        return courseNavigationController
    }()

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        let userActivity = connectionOptions.userActivities.first ?? session.stateRestorationActivity
        guard let courseId = userActivity?.userInfo?["courseID"] as? String else { return }

        let fetchRequest = CourseHelper.FetchRequest.course(withSlugOrId: courseId)
        guard let course = CoreDataHelper.viewContext.fetchSingle(fetchRequest).value else { return }

        let topViewController = self.courseNavigationController.topViewController.require(hint: "Top view controller required")
        let courseViewController = topViewController.require(toHaveType: CourseViewController.self)
        courseViewController.course = course

        if let windowScene = scene as? UIWindowScene {
            self.window = UIWindow(windowScene: windowScene)
            self.window?.rootViewController = self.courseNavigationController
            self.window?.tintColor = Brand.default.colors.window
            self.window?.makeKeyAndVisible()
        }
    }

    func sceneWillResignActive(_ scene: UIScene) {
        AppDelegate.instance().setHomescreenQuickActions()
    }

    func stateRestorationActivity(for scene: UIScene) -> NSUserActivity? {
        return scene.userActivity
    }

}