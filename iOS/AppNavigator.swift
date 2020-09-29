//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import CoreSpotlight
import UIKit

// swiftlint:disable type_body_length
class AppNavigator {

    private weak var currentCourseNavigationController: CourseNavigationController?
    private let courseTransitioningDelegate = CourseTransitioningDelegate() // swiftlint:disable:this weak_delegate

    private weak var tabBarController: UITabBarController?

    init(tabBarController: UITabBarController) {
        self.tabBarController = tabBarController
    }

    @discardableResult func handle(userActivity: NSUserActivity) -> Bool {
        var activityURL: URL?
        if userActivity.activityType == CSSearchableItemActionType {
            // This activity represents an item indexed using Core Spotlight, so restore the context related to the unique identifier.
            // Note that the unique identifier of the Core Spotlight item is set in the activity’s userInfo property
            // for the key CSSearchableItemActivityIdentifier.
            if let uniqueIdentifier = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String {
                activityURL = URL(string: uniqueIdentifier)
            }
        } else if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
            activityURL = userActivity.webpageURL
        }

        guard let url = activityURL else {
            return false
        }

        let wasHandleByApplication = self.handle(url: url, userInitialized: false)

        if !wasHandleByApplication {
            UIApplication.shared.open(url)
        }

        return wasHandleByApplication
    }

    func handle(url: URL, on sourceViewController: UIViewController, userInitialized: Bool) -> Bool {
        guard let url = self.sanitizedURL(for: url) else {
            logger.error("URL in Markdown or Markdownparser is broken")
            return false
        }

        if self.handle(url: url, userInitialized: true) {
            return true
        }

        guard url.host == Brand.default.host else {
            logger.debug("Can't open \(url) inside of the app because host is wrong")
            return false
        }

        let webViewController = R.storyboard.webViewController.instantiateInitialViewController().require()
        webViewController.url = url
        sourceViewController.navigationController?.pushViewController(webViewController, animated: trueUnlessReduceMotionEnabled)

        return true
    }

    @discardableResult func handle(url: URL, userInitialized: Bool) -> Bool {
        if url.scheme == Bundle.main.urlScheme {
            return self.handle(urlSchemeURL: url)
        } else if url.host == Brand.default.host {
            return self.handle(hostURL: url, userInitialized: userInitialized)
        } else {
            logger.debug("Can't open \(url) inside of the app because host or url scheme is wrong")
            return false
        }
    }

    private func handle(urlSchemeURL url: URL) -> Bool {
        switch url.host {
        case "dashboard":
            return self.showDashboard()
        default:
            return true
        }
    }

    private func handle(hostURL url: URL, userInitialized: Bool) -> Bool {
        switch url.pathComponents[safe: 1] {
        case nil:
            return true // url to base page, simply open the app
        case "courses":
            return self.handleCourseURL(url, userInitialized: userInitialized)
        case "dashboard":
            return self.showDashboard()
        default:
            return false
        }
    }

    private func sanitizedURL(for url: URL) -> URL? {
        guard url.host != nil else {
            // make relative URL relative to base route
            return Routes.base.appendingPathComponent(url.absoluteString)
        }

        guard url.scheme?.hasPrefix("http") ?? false else {
            // don't allow HTTP
            return nil
        }

        return url
    }

    private func handleCourseURL(_ url: URL, userInitialized: Bool) -> Bool {
        guard let slugOrId = url.pathComponents[safe: 2] else {
            self.showCourseList()
            return true
        }

        let fetchRequest = CourseHelper.FetchRequest.course(withSlugOrId: slugOrId)
        var canOpenInApp = false

        CoreDataHelper.viewContext.performAndWait {
            switch CoreDataHelper.viewContext.fetchSingle(fetchRequest) {
            case let .success(course):
                canOpenInApp = self.handle(url: url, for: course, userInitialized: userInitialized)
            case let .failure(error):
                logger.info("Could not find course in local database: \(error)")
            }
        }

        return canOpenInApp
    }

    private func handle(url: URL, for course: Course, userInitialized: Bool) -> Bool {
        let courseArea = url.pathComponents[safe: 3]
        switch courseArea {
        case nil:
            self.show(course: course, with: .courseDetails, userInitialized: userInitialized)
            return true
        case "items":
            return self.handleCourseItemURL(url, for: course)
        case "pinboard":
            self.show(course: course, with: .discussions, userInitialized: userInitialized)
            return true
        case "progress":
            self.show(course: course, with: .progress, userInitialized: userInitialized)
            return true
        case "announcements":
            self.show(course: course, with: .announcements, userInitialized: userInitialized)
            return true
        case "recap":
            guard Brand.default.features.enableRecap else { return false }
            self.show(course: course, with: .recap, userInitialized: userInitialized)
            return true
        case "documents":
            guard Brand.default.features.enableDocuments else { return false }
            self.show(course: course, with: .documents, userInitialized: userInitialized)
            return true
        default:
            logger.info("Unable to open course area (\(courseArea ?? "")) for course (\(course.slug ?? "-")) inside the app")
            return false
        }
    }

    private func handleCourseItemURL(_ url: URL, for course: Course) -> Bool {
        if let courseItemId = url.pathComponents[safe: 4] {
            let itemId = CourseItem.uuid(forBase62UUID: courseItemId) ?? courseItemId
            let itemFetchRequest = CourseItemHelper.FetchRequest.courseItem(withId: itemId)
            if let courseItem = CoreDataHelper.viewContext.fetchSingle(itemFetchRequest).value {
                self.show(item: courseItem)
                return true
            } else {
                logger.info("Unable to open course item (\(itemId)) for course (\(course.slug ?? "-")) inside the app")
                return false
            }
        } else {
            self.show(course: course, with: .learnings, userInitialized: true)
            return true
        }
    }

    func handle(shortcutItem: UIApplicationShortcutItem) {
        guard let courseId = shortcutItem.userInfo?["courseID"] as? String else { return }
        let fetchRequest = CourseHelper.FetchRequest.course(withSlugOrId: courseId)
        guard let course = CoreDataHelper.viewContext.fetchSingle(fetchRequest).value else { return }
        self.show(course: course, userInitialized: false)
    }

    func showDashboard() -> Bool {
        // Close current course
        self.currentCourseNavigationController?.closeCourse()
        self.currentCourseNavigationController = nil

        if UserProfileHelper.shared.isLoggedIn {
            self.tabBarController?.selectedIndex = XikoloTabBarController.Tabs.dashboard.index
        } else {
            self.presentDashboardLoginViewController()
        }

        return true
    }

    func showCourseList() {
        // Close current course
        self.currentCourseNavigationController?.closeCourse()
        self.currentCourseNavigationController = nil

        self.tabBarController?.selectedIndex = XikoloTabBarController.Tabs.courses.index
    }

    typealias CourseOpenAction = (CourseViewController) -> Void
    typealias CourseClosedAction = (CourseViewController, Bool) -> Void

    func navigate(to course: Course, courseArea: CourseArea, courseOpenAction: CourseOpenAction, courseClosedAction: CourseClosedAction) {
        let currentlyPresentsCourse = self.currentCourseNavigationController?.view.window != nil
        let someCourseViewController = self.currentCourseNavigationController?.courseViewController

        if let courseViewController = someCourseViewController, courseViewController.course.id == course.id, currentlyPresentsCourse {
            if course.accessible || courseArea.accessibleWithoutEnrollment {
                self.currentCourseNavigationController?.popToRootViewController(animated: trueUnlessReduceMotionEnabled)
                courseOpenAction(courseViewController)
            }

            return
        }

        self.currentCourseNavigationController?.closeCourse()
        self.currentCourseNavigationController = nil

        let courseNavigationController = R.storyboard.course.instantiateInitialViewController().require()
        let topViewController = courseNavigationController.topViewController.require(hint: "Top view controller required")
        let courseViewController = topViewController.require(toHaveType: CourseViewController.self)
        courseViewController.course = course

        let accessible = course.accessible || courseArea.accessibleWithoutEnrollment
        courseClosedAction(courseViewController, accessible)

        self.currentCourseNavigationController = courseNavigationController

        courseNavigationController.transitioningDelegate = self.courseTransitioningDelegate
        courseNavigationController.modalPresentationStyle = .custom
        courseNavigationController.modalPresentationCapturesStatusBarAppearance = true

        self.tabBarController?.present(courseNavigationController, animated: trueUnlessReduceMotionEnabled) {
            CourseHelper.visit(course)
        }
    }

    func myfunction(course: Course, courseArea: CourseArea) {
        self.currentCourseNavigationController?.closeCourse()
        self.currentCourseNavigationController = nil

        let courseNavigationController = R.storyboard.course.instantiateInitialViewController().require()
        let topViewController = courseNavigationController.topViewController.require(hint: "Top view controller required")
        let courseViewController = topViewController.require(toHaveType: CourseViewController.self)
        courseViewController.course = course
    }

    func show(course: Course, with courseArea: CourseArea = .learnings, userInitialized: Bool) {
        let courseOpenAction: CourseOpenAction = { courseViewController in
            courseViewController.transitionIfPossible(to: courseArea)
        }

        let courseClosedAction: CourseClosedAction = { courseViewController, accessible in
            courseViewController.transitionIfPossible(to: courseArea)
        }

        if #available(iOS 13, *), userInitialized, UIDevice.current.userInterfaceIdiom == .pad {
            let alert = UIAlertController(title: NSLocalizedString("course.open-alert",
                                                                   comment: "Question posed when a course is about to get opened via link"),
                                          message: nil,
                                          preferredStyle: .alert)
            // swiftlint:disable:next trailing_closure
            let openInCurrentWindowAction = UIAlertAction(title: NSLocalizedString("course.open-this.window", comment: "Open course in this window"),
                                                          style: .default,
                                                          handler: { _ in self.navigate(to: course,
                                                                                        courseArea: courseArea,
                                                                                        courseOpenAction: courseOpenAction,
                                                                                        courseClosedAction: courseClosedAction)
            })

            let openInAnotherWindowAction = UIAlertAction(title: NSLocalizedString("course.open-another.window", comment: "open course in another window"),
                                                          style: .default,
                                                          handler: nil)
            alert.addCancelAction()
            alert.addAction(openInCurrentWindowAction)
            alert.addAction(openInAnotherWindowAction)
            alert.popoverPresentationController?.sourceView = self.tabBarController?.view
            self.currentCourseNavigationController?.present(alert, animated: trueUnlessReduceMotionEnabled)
        } else {
            self.navigate(to: course, courseArea: courseArea, courseOpenAction: courseOpenAction, courseClosedAction: courseClosedAction)
        }
    }

    func show(item: CourseItem) {
        guard let course = item.section?.course else { return }

        let courseOpenAction: CourseOpenAction = { courseViewController in
            courseViewController.show(item: item, animated: trueUnlessReduceMotionEnabled)
        }

        let courseClosedAction: CourseClosedAction = { courseViewController, accessible in
            guard accessible else { return }
            courseViewController.show(item: item, animated: false)
        }

        self.navigate(to: course, courseArea: .learnings, courseOpenAction: courseOpenAction, courseClosedAction: courseClosedAction)
    }

    func show(documentLocalization: DocumentLocalization) {
        guard let course = documentLocalization.document.courses.first else { return }

        let courseOpenAction: CourseOpenAction = { courseViewController in
            courseViewController.show(documentLocalization: documentLocalization, animated: trueUnlessReduceMotionEnabled)
        }

        let courseClosedAction: CourseClosedAction = { courseViewController, accessible in
            guard accessible else { return }
            courseViewController.show(documentLocalization: documentLocalization, animated: false)
        }

        self.navigate(to: course, courseArea: .documents, courseOpenAction: courseOpenAction, courseClosedAction: courseClosedAction)
    }

    func presentDashboardLoginViewController() {
        let loginNavigationController = R.storyboard.login.instantiateInitialViewController().require()
        let firstViewController = loginNavigationController.viewControllers.first.require()
        let loginViewController = firstViewController.require(toHaveType: LoginViewController.self)

        loginViewController.delegate = self

        self.tabBarController?.present(loginNavigationController, animated: trueUnlessReduceMotionEnabled)
    }

}

extension AppNavigator: LoginDelegate {

    func didSuccessfullyLogin() {
        self.tabBarController?.selectedIndex = XikoloTabBarController.Tabs.dashboard.index
    }

}
