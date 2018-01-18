//
//  AppNavigator.swift
//  xikolo-ios
//
//  Created by Max Bothe on 12.12.17.
//  Copyright © 2017 HPI. All rights reserved.
//

import UIKit
import CoreSpotlight

struct AppNavigator {

    static func handle(userActivity: NSUserActivity, forApplication application: UIApplication, on tabBarController: UITabBarController?) -> Bool {
        var activityURL: URL?
        if userActivity.activityType == CSSearchableItemActionType {
            // This activity represents an item indexed using Core Spotlight, so restore the context related to the unique identifier.
            // Note that the unique identifier of the Core Spotlight item is set in the activity’s userInfo property for the key CSSearchableItemActivityIdentifier.
            if let uniqueIdentifier = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String {
                activityURL = URL(string: uniqueIdentifier)
            }
            // this contains the courses uuid
            // Next, find and open the item specified by uniqueIdentifer.
        } else {
            activityURL = userActivity.webpageURL
        }

        guard let url = activityURL else {
            log.error("Failed to load url for user activity")
            return false
        }

        guard let tabBarController = tabBarController else {
            log.error("UITabBarController could not be found")
            return false
        }

        guard url.pathComponents.count > 1 else {
            log.error("Invalid url for user activity")
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

        // We can't handle the url, open it with a browser
        let webpageUrl = url
        application.open(webpageUrl)
        return false
    }

    static func show(course: Course, on tabBarController: UITabBarController?) {
        guard let courseNavigationController = tabBarController?.viewControllers?[safe: 1] as? UINavigationController else {
            log.error("CourseNavigationController could not be found")
            return
        }

        courseNavigationController.popToRootViewController(animated: false)

        let vc = UIStoryboard(name: "TabCourses", bundle: nil).instantiateViewController(withIdentifier: "CourseDecisionViewController")

        guard let courseDecisionViewController = vc as? CourseDecisionViewController else {
            log.error("CourseDecisionViewController could not be found")
            return
        }

        courseDecisionViewController.course = course
        courseDecisionViewController.content = course.accessible ? .learnings : .courseDetails
        courseNavigationController.pushViewController(courseDecisionViewController, animated: false)

        tabBarController?.selectedIndex = 1
    }
}
