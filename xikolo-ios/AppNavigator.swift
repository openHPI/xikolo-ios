//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import CoreSpotlight
import SafariServices
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

    static func handle(_ url: URL, on sourceVC: UIViewController) -> Bool {
        guard let url = MarkdownHelper.trueScheme(for: url) else {
            log.error("URL in Markdown or Markdownparser is broken")
            return false
        }
        
        if self.handle(url) {
            return false
        }

        if url.host == Brand.Host {
            let storyboard = UIStoryboard(name: "CourseContent", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "WebViewController").require(toHaveType: WebViewController.self)
            vc.url = url.absoluteString
            sourceVC.navigationController?.pushViewController(vc, animated: true)
            return false
        }

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
        guard hostURL == Brand.Host else {
            log.debug("Can't open \(url) inside of the app because host is wrong")
            return false
        }

        guard url.pathComponents.count > 1 else {
            // simply open the app
            return true
        }

        if url.pathComponents[safe: 1] == "courses" {
            if let slugOrId = url.pathComponents[safe: 2] {
                let fetchRequest = CourseHelper.FetchRequest.course(withSlugOrId: slugOrId)
                var couldFindCourse = false

                CoreDataHelper.viewContext.performAndWait {
                    switch CoreDataHelper.viewContext.fetchSingle(fetchRequest) {
                    case .success(let course):
                        couldFindCourse = true
                        self.show(course: course, on: tabBarController)
                    case .failure(let error):
                        log.info("Could not find course in local database: \(error)")
                    }
                }

                // sync course or get course if not in local database
                let courseFuture = CourseHelper.syncCourse(forSlugOrId: slugOrId)

                if couldFindCourse {
                    return true
                } else if case .success(_)? = courseFuture.forced(30.seconds.fromNow) {  // we only wait 30 seconds
                    return true
                }
            } else {
                tabBarController.selectedIndex = 1
                return true
            }
        }
        return false
    }

    static func show(course: Course, on tabBarController: UITabBarController?) {
        guard let courseNavigationController = tabBarController?.viewControllers?[safe: 1] as? UINavigationController else {
            let reason = "CourseNavigationController could not be found"
            CrashlyticsHelper.shared.recordCustomExceptionName("Storyboard Error", reason: reason, frameArray: [])
            log.error(reason)
            return
        }

        courseNavigationController.popToRootViewController(animated: false)

        let vc = UIStoryboard(name: "TabCourses", bundle: nil).instantiateViewController(withIdentifier: "CourseDecisionViewController")

        guard let courseDecisionViewController = vc as? CourseDecisionViewController else {
            let reason = "CourseDecisionViewController could not be found"
            CrashlyticsHelper.shared.recordCustomExceptionName("Storyboard Error", reason: reason, frameArray: [])
            log.error(reason)
            return
        }

        courseDecisionViewController.course = course
        courseDecisionViewController.content = course.accessible ? .learnings : .courseDetails
        courseNavigationController.pushViewController(courseDecisionViewController, animated: false)

        tabBarController?.selectedIndex = 1
    }
}
