//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import CoreSpotlight
import UIKit

class AppNavigator {

    static func handle(userActivity: NSUserActivity, forApplication application: UIApplication, on tabBarController: UITabBarController?) -> Bool {
        var activityURL: URL?
        if userActivity.activityType == CSSearchableItemActionType {
            // This activity represents an item indexed using Core Spotlight, so restore the context related to the unique identifier.
            // Note that the unique identifier of the Core Spotlight item is set in the activity’s userInfo property
            // for the key CSSearchableItemActivityIdentifier.
            if let uniqueIdentifier = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String {
                activityURL = URL(string: uniqueIdentifier)
            }
        } else {
            activityURL = userActivity.webpageURL
        }

        guard let url = activityURL else {
            return false
        }

        if handle(url) {
            return true
        }

        // We can't handle the url, open it with a browser
        let webpageUrl = url
        application.open(webpageUrl)
        return false
    }

    static func handle(_ url: URL, on sourceViewController: UIViewController) -> Bool {
        guard let url = MarkdownHelper.trueScheme(for: url) else {
            log.error("URL in Markdown or Markdownparser is broken")
            return false
        }

        if self.handle(url) {
            return true
        }

        guard url.host == Brand.host else {
            log.debug("Can't open \(url) inside of the app because host is wrong")
            return false
        }

        let storyboard = UIStoryboard(name: "CourseContent", bundle: nil)
        let webViewController = storyboard.instantiateViewController(withIdentifier: "WebViewController").require(toHaveType: WebViewController.self)
        webViewController.url = url
        sourceViewController.navigationController?.pushViewController(webViewController, animated: true)
        return true
    }

    static func handle(_ url: URL) -> Bool {
        guard let tabBarController = AppDelegate.instance().tabBarController else {
            let reason = "UITabBarController could not be found"
            CrashlyticsHelper.shared.recordCustomExceptionName("Storyboard Error", reason: reason, frameArray: [])
            log.error(reason)
            return false
        }

        guard let hostURL = url.host else { return false }
        guard hostURL == Brand.host else {
            log.debug("Can't open \(url) inside of the app because host is wrong")
            return false
        }

        switch url.pathComponents[safe: 1] {
        case nil:
            return true // url to base page, simply open the app
        case "courses":
            return self.handleCourseURL(url, on: tabBarController)
        default:
            return false
        }
    }

    private static func handleCourseURL(_ url: URL, on tabBarController: UITabBarController) -> Bool {
        guard let slugOrId = url.pathComponents[safe: 2] else {
            // url points to courses list
            tabBarController.selectedIndex = 1
            return true
        }

        let fetchRequest = CourseHelper.FetchRequest.course(withSlugOrId: slugOrId)
        var couldFindCourse = false
        var canOpenInApp = true

        CoreDataHelper.viewContext.performAndWait {
            switch CoreDataHelper.viewContext.fetchSingle(fetchRequest) {
            case .success(let course):
                couldFindCourse = true
                let courseArea = url.pathComponents[safe: 3]
                if courseArea == nil {
                    self.show(course: course, with: .courseDetails, on: tabBarController)
                } else if courseArea == "items" {
                    self.show(course: course, with: .learnings, on: tabBarController)
                } else if courseArea == "pinboard" {
                    self.show(course: course, with: .discussions, on: tabBarController)
                } else if courseArea == "announcements" {
                    self.show(course: course, with: .announcements, on: tabBarController)
                } else {
                    // We dont support this yet, so we should just open the url with some kind of browser
                    log.info("Unable to open course area (\(courseArea ?? "")) for course (\(slugOrId)) inside the app")
                    canOpenInApp = false
                }
            case .failure(let error):
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
        } else if case .success(_)? = courseFuture.forced(30.seconds.fromNow) {  // we only wait 30 seconds
            return true
        }

        return false
    }

    static func show(course: Course, with content: CourseDecisionViewController.CourseContent = .learnings, on tabBarController: UITabBarController?) {
        guard let courseNavigationController = tabBarController?.viewControllers?[safe: 1] as? UINavigationController else {
            let reason = "CourseNavigationController could not be found"
            CrashlyticsHelper.shared.recordCustomExceptionName("Storyboard Error", reason: reason, frameArray: [])
            log.error(reason)
            return
        }

        courseNavigationController.popToRootViewController(animated: false)

        let viewController = UIStoryboard(name: "TabCourses", bundle: nil).instantiateViewController(withIdentifier: "CourseDecisionViewController")

        guard let courseDecisionViewController = viewController as? CourseDecisionViewController else {
            let reason = "CourseDecisionViewController could not be found"
            CrashlyticsHelper.shared.recordCustomExceptionName("Storyboard Error", reason: reason, frameArray: [])
            log.error(reason)
            return
        }

        courseDecisionViewController.course = course
        courseNavigationController.pushViewController(courseDecisionViewController, animated: false)
        if course.accessible {
            courseDecisionViewController.content = content
        } else {
            courseDecisionViewController.content = .courseDetails
        }

        tabBarController?.selectedIndex = 1
    }
}
