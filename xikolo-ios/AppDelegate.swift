//
//  AppDelegate.swift
//  xikolo-ios
//
//  Created by Jan Renz on 25/06/15.
//  Copyright © 2015 HPI. All rights reserved.
//

import CoreData
import UIKit
import PinpointKit
import SDWebImage

@UIApplicationMain
class AppDelegate : AbstractAppDelegate {

    private static let pinpointKit = PinpointKit(feedbackRecipients: ["openhpi-info@hpi.de"])
    var window: UIWindow? = ShakeDetectingWindow(frame: UIScreen.main.bounds, delegate: AppDelegate.pinpointKit)


    class func instance() -> AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }

    override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        window?.tintColor = Brand.TintColor
        updateAnnouncements()
        EnrollmentHelper.syncEnrollments()

        #if OPENSAP
            // The openSAP backend uses a special certificate, which lets SDWebImage to cancel the requests.
            // By setting 'username' and 'password', a dummy certificate is created that allows the request
            // of SDWebImage to pass.
            // See 'SDWebImageDownloaderOperation.urlSession(_:task:didReceive:completionHandler:)'
            // SDWebImage (ver. 4.0.0) -> SDWebImageDownloaderOperation -> Line 408
            SDWebImageDownloader.shared().username = "open"
            SDWebImageDownloader.shared().password = "SAP"
        #endif

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    func application(_ application: UIApplication,
                     continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([Any]?) -> Void) -> Bool {

        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb, let url = userActivity.webpageURL else { return false }
        guard let rootViewController = self.window?.rootViewController as? UITabBarController else {
            print("UITabBarController could not be found")
            return false
        }
        switch url.lastPathComponent {
        case "courses":
            rootViewController.selectedIndex = 1
        case "dashboard":
            rootViewController.selectedIndex = 0
        case "news":
            rootViewController.selectedIndex = 2
        default:
            break
        }
        
        // we can't handle the url, open it with a browser
        let webpageUrl = url
        application.openURL(webpageUrl)
        return false
    }

    func updateAnnouncements() {
        AnnouncementHelper.syncAnnouncements().onSuccess { (announcements) in // sync announcements and show badge on news tab with number of unread articles
            if let rootViewController = self.window?.rootViewController as? UITabBarController {
                if let tabArray = rootViewController.tabBar.items {
                    let tabItem = tabArray[2]
                    let unreadAnnouncements = announcements.filter({ !($0.visited ?? true ) }) // we get nil if the user is not logged in. In this case we don't want to show the badge
                    if unreadAnnouncements.count > 0 {
                        tabItem.badgeValue = String(unreadAnnouncements.count)
                    } else {
                        tabItem.badgeValue = nil
                    }
                }
            }
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    override func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        super.applicationWillTerminate(application)
    }

    func goToCourse(_ course: Course) {
        guard let rootViewController = self.window?.rootViewController as? UITabBarController else {
            print("UITabBarController could not be found")
            return
        }
        guard let courseNavigationController = rootViewController.viewControllers?[1] as? UINavigationController else {
            print("CourseNavigationController could not be found")
            return
        }

        courseNavigationController.popToRootViewController(animated: false)

        let vc = UIStoryboard(name: "TabCourses", bundle: nil).instantiateViewController(withIdentifier: "CourseDecisionViewController")

        guard let courseDecisionViewController = vc as? CourseDecisionViewController else {
            print("CourseDecisionViewController could not be found")
            return
        }

        courseDecisionViewController.course = course
        courseDecisionViewController.content = course.accessible ? .learnings : .courseDetails
        courseNavigationController.pushViewController(courseDecisionViewController, animated: false)

        rootViewController.selectedIndex = 1
    }

}
