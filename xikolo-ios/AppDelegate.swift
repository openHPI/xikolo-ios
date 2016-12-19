//
//  AppDelegate.swift
//  xikolo-ios
//
//  Created by Jan Renz on 25/06/15.
//  Copyright © 2015 HPI. All rights reserved.
//

import CoreData
import UIKit

@UIApplicationMain
class AppDelegate : AbstractAppDelegate {

    class func instance() -> AppDelegate {
        return UIApplication.sharedApplication().delegate as! AppDelegate
    }

    override func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        window?.tintColor = Brand.TintColor
        updateNews()

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    func updateNews() {
        NewsArticleHelper.syncNewsArticles().onSuccess { (newsArticles) in // sync news and show badge on news tab with number of unread articles
            if let rootViewController = self.window?.rootViewController as? UITabBarController {
                if let tabArray = rootViewController.tabBar.items {
                    let tabItem = tabArray[2]
                    let unreadNewsArticles = newsArticles.filter({ !($0.visited ?? true ) }) // we get nil if the user is not logged in. In this case we don't want to show the badge
                    if unreadNewsArticles.count > 0 {
                        tabItem.badgeValue = String(unreadNewsArticles.count)
                    } else {
                        tabItem.badgeValue = nil
                    }
                }
            }
        }
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    override func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        super.applicationWillTerminate(application)
    }

    func goToCourse(course: Course, content: CourseDecisionViewController.CourseContent = .learnings) {
        guard let rootViewController = self.window?.rootViewController as? UITabBarController else {
            print("UITabBarController could not be found")
            return
        }
        guard let courseNavigationController = rootViewController.viewControllers?[1] as? UINavigationController else {
            print("CourseNavigationController could not be found")
            return
        }

        courseNavigationController.popToRootViewControllerAnimated(false)

        let vc = UIStoryboard(name: "TabCourses", bundle: nil).instantiateViewControllerWithIdentifier("CourseDecisionViewController")

        guard let courseDecisionViewController = vc as? CourseDecisionViewController else {
            print("CourseDecisionViewController could not be found")
            return
        }

        courseDecisionViewController.course = course
        courseDecisionViewController.content = content
        courseNavigationController.pushViewController(courseDecisionViewController, animated: false)

        rootViewController.selectedIndex = 1
    }

}
