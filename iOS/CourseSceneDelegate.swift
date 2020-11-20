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

    private var themeObservation: NSKeyValueObservation?

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        let userActivity = connectionOptions.userActivities.first ?? session.stateRestorationActivity
        guard let courseId = userActivity?.userInfo?["courseID"] as? String else { return }

        let fetchRequest = CourseHelper.FetchRequest.course(withSlugOrId: courseId)
        guard let course = CoreDataHelper.viewContext.fetchSingle(fetchRequest).value else { return }

        let topViewController = self.courseNavigationController.topViewController.require(hint: "Top view controller required")
        let courseViewController = topViewController.require(toHaveType: CourseViewController.self)
        courseViewController.course = course

        let courseAction: (CourseViewController, Bool) -> Void = { courseViewController, accessible in
            if let url = userActivity?.userInfo?["url"] as? URL {
                let courseArea = url.pathComponents[safe: 3]
                switch courseArea {
                case nil:
                    courseViewController.transitionIfPossible(to: .learnings)
                case "items":
                    if let courseItemId = url.pathComponents[safe: 4] {
                        let itemId = CourseItem.uuid(forBase62UUID: courseItemId) ?? courseItemId
                        let itemFetchRequest = CourseItemHelper.FetchRequest.courseItem(withId: itemId)
                        if let courseItem = CoreDataHelper.viewContext.fetchSingle(itemFetchRequest).value {
                            courseViewController.show(item: courseItem, animated: trueUnlessReduceMotionEnabled)
                        } else {
                            logger.info("Unable to open course item (\(itemId)) for course (\(course.slug ?? "-")) inside the app")
//                            return false
                            courseViewController.transitionIfPossible(to: .learnings)
                        }
                    } else {
                        courseViewController.transitionIfPossible(to: .learnings)
                    }
                case "pinboard":
                    courseViewController.transitionIfPossible(to: .discussions)
                case "progress":
                    courseViewController.transitionIfPossible(to: .progress)
                case "announcements":
                    courseViewController.transitionIfPossible(to: .announcements)
                case "recap":
                    guard Brand.default.features.enableRecap else { return }
                    courseViewController.transitionIfPossible(to: .recap)
                case "documents":
                    guard Brand.default.features.enableDocuments else { return }
                    courseViewController.transitionIfPossible(to: .documents)
                default:
                    logger.info("Unable to open course area (\(courseArea ?? "")) for course (\(course.slug ?? "-")) inside the app")
                    courseViewController.transitionIfPossible(to: .learnings)
                }
            } else {
                courseViewController.transitionIfPossible(to: .learnings)
            }
        }

        let accessible = course.accessible
        courseAction(courseViewController, accessible)

        if let windowScene = scene as? UIWindowScene {
            self.window = UIWindow(windowScene: windowScene)
            self.window?.rootViewController = self.courseNavigationController
            self.window?.tintColor = Brand.default.colors.window
            self.window?.makeKeyAndVisible()
        }

        self.themeObservation = UserDefaults.standard.observe(\UserDefaults.theme, options: [.initial, .new]) { [weak self] _, _ in
            self?.window?.overrideUserInterfaceStyle = UserDefaults.standard.theme.userInterfaceStyle
        }
    }

    func sceneWillResignActive(_ scene: UIScene) {
        QuickActionHelper.setHomescreenQuickActions()
    }

    func stateRestorationActivity(for scene: UIScene) -> NSUserActivity? {
        return scene.userActivity
    }

}
