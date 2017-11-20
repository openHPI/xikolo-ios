//
//  AppDelegate.swift
//  xikolo-ios
//
//  Created by Jan Renz on 25/06/15.
//  Copyright © 2015 HPI. All rights reserved.
//

import CoreData
import UIKit
import SDWebImage
import CoreSpotlight

@UIApplicationMain
class AppDelegate : AbstractAppDelegate {

    var window: UIWindow?

    class func instance() -> AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }

    override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        window?.tintColor = Brand.TintColor

        UserProfileHelper.migrateLegacyKeychain()
        AnnouncementHelper.syncAllAnnouncements()
        EnrollmentHelper.syncEnrollments()

        VideoPersistenceManager.shared.restorePersistenceManager()

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
            print("Failed to load url for user activity")
            return false
        }

        guard let rootViewController = self.window?.rootViewController as? UITabBarController else {
            print("UITabBarController could not be found")
            return false
        }

        guard url.pathComponents.count > 1 else {
            print("Invalid url for user activity")
            return false
        }

        switch url.pathComponents[1] {
            case "courses":
                if url.pathComponents.count > 2{
                    //support /courses/slug -> course detail page or learning
                    let slug = url.pathComponents[2]
                    //get course by slug
                    //todo the course might not be synced yet, than we could try to fetch from the API by slug
                    let fetchRequest = CourseHelper.FetchRequest.course(withSlug: slug)

                    let result = CoreDataHelper.fetchSingleObjectAndWait(fetchRequest: fetchRequest, inContext: .viewContext) { course in
                        self.goToCourse(course)
                    }

                    switch result {
                    case .success(_):
                        return true
                    case .failure(let error):
                        print("Warning: could not find course: \(error)")
                    }
                } else {
                    rootViewController.selectedIndex = 1
                }
            case "dashboard":
                rootViewController.selectedIndex = 0
            case "news":
                rootViewController.selectedIndex = 2
            default:
                break
        }

        // we can't handle the url, open it with a browser
        let webpageUrl = url
        application.open(webpageUrl)
        return false
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
