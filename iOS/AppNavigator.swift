//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import CoreSpotlight
import UIKit

enum AppNavigator {

    private static weak var currentCourseNavigationController: CourseNavigationController?
    private static let courseTransitioningDelegate = CourseTransitioningDelegate()

    static func handle(userActivity: NSUserActivity) -> Bool {
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

        return self.handle(url: url)
    }

    static func handle(url: URL, on sourceViewController: UIViewController) -> Bool {
        guard let url = self.sanitizedURL(for: url) else {
            log.error("URL in Markdown or Markdownparser is broken")
            return false
        }

        if self.handle(url: url) {
            return true
        }

        guard url.host == Brand.default.host else {
            log.debug("Can't open \(url) inside of the app because host is wrong")
            return false
        }

        let webViewController = R.storyboard.webViewController.instantiateInitialViewController().require()
        webViewController.url = url
        sourceViewController.navigationController?.pushViewController(webViewController, animated: trueUnlessReduceMotionEnabled)

        return true
    }

    static func handle(url: URL) -> Bool {
        guard url.host == Brand.default.host else {
            log.debug("Can't open \(url) inside of the app because host is wrong")
            return false
        }

        switch url.pathComponents[safe: 1] {
        case nil:
            return true // url to base page, simply open the app
        case "courses":
            return self.handleCourseURL(url)
        default:
            return false
        }
    }

    private static func sanitizedURL(for url: URL) -> URL? {
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

    private static func handleCourseURL(_ url: URL) -> Bool {
        guard let slugOrId = url.pathComponents[safe: 2] else {
            return self.showCourseList()
        }

        let fetchRequest = CourseHelper.FetchRequest.course(withSlugOrId: slugOrId)
        var couldFindCourse = false
        var canOpenInApp = true

        CoreDataHelper.viewContext.performAndWait {
            switch CoreDataHelper.viewContext.fetchSingle(fetchRequest) {
            case let .success(course):
                couldFindCourse = true
                let courseArea = url.pathComponents[safe: 3]
                if courseArea == nil {
                    self.show(course: course, with: .courseDetails)
                } else if courseArea == "items" {
                    self.show(course: course, with: .learnings)
                } else if courseArea == "pinboard" {
                    self.show(course: course, with: .discussions)
                } else if courseArea == "announcements" {
                    self.show(course: course, with: .announcements)
                } else {
                    // We dont support this yet, so we should just open the url with some kind of browser
                    log.info("Unable to open course area (\(courseArea ?? "")) for course (\(slugOrId)) inside the app")
                    canOpenInApp = false
                }
            case let .failure(error):
                log.info("Could not find course in local database: \(error)")
            }
        }

        guard canOpenInApp else {
            return false
        }

        // sync course or get course if not in local database
        let courseFuture = CourseHelper.syncCourse(forSlugOrId: slugOrId)

        if couldFindCourse {
            return true
        } else if courseFuture.forced(10.seconds.fromNow)?.value != nil {  // we only wait for 10 seconds
            return true
        }

        return false
    }

    @discardableResult static func showCourseList() -> Bool {
        return AppDelegate.instance().switchToCourseListTab()
    }

    typealias CourseOpenAction = (CourseViewController) -> Void
    typealias CourseClosedAction = (CourseViewController, Bool) -> Void

    static func navigate(to course: Course,
                         courseArea: CourseArea,
                         courseOpenAction: CourseOpenAction,
                         courseClosedAction: CourseClosedAction) {
        let currentlyPresentsCourse = self.currentCourseNavigationController?.view.window != nil
        let someCourseViewController = self.currentCourseNavigationController?.courseViewController

        if let courseViewController = someCourseViewController, courseViewController.course.id == course.id, currentlyPresentsCourse {
            if course.accessible || courseArea.acessibleWithoutEnrollment {
                self.currentCourseNavigationController?.popToRootViewController(animated: trueUnlessReduceMotionEnabled)
                courseOpenAction(courseViewController)
            }

            return
        }

        self.currentCourseNavigationController?.closeCourse()
        self.currentCourseNavigationController = nil

        let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
        feedbackGenerator.prepare()

        guard let rootViewController = UIApplication.shared.keyWindow?.rootViewController else {
            let reason = "root view controller could not be found"
            log.error(reason)
            return
        }

        let courseNavigationController = R.storyboard.course.instantiateInitialViewController().require()
        let topViewController = courseNavigationController.topViewController.require(hint: "Top view controller required")
        let courseViewController = topViewController.require(toHaveType: CourseViewController.self)
        courseViewController.course = course

        let accessible = course.accessible || courseArea.acessibleWithoutEnrollment
        courseClosedAction(courseViewController, accessible)

        self.currentCourseNavigationController = courseNavigationController

        courseNavigationController.transitioningDelegate = self.courseTransitioningDelegate
        courseNavigationController.modalPresentationStyle = .custom
        courseNavigationController.modalPresentationCapturesStatusBarAppearance = true

        feedbackGenerator.impactOccurred()

        rootViewController.present(courseNavigationController, animated: trueUnlessReduceMotionEnabled) {
            CourseHelper.visit(course)
        }
    }

    static func show(course: Course, with courseArea: CourseArea = .learnings) {
        let courseOpenAction: CourseOpenAction = { courseViewController in
            courseViewController.area = courseArea
        }

        let courseClosedAction: CourseClosedAction = { courseViewController, accessible in
            if accessible {
                courseViewController.area = courseArea
            } else {
                courseViewController.area = .courseDetails
            }
        }

        self.navigate(to: course, courseArea: courseArea, courseOpenAction: courseOpenAction, courseClosedAction: courseClosedAction)
    }

    static func show(item: CourseItem) {
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

    static func show(documentLocalization: DocumentLocalization) {
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

}
