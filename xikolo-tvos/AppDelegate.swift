//
//  AppDelegate.swift
//  xikolo-tvos
//
//  Created by Sebastian Brückner on 19.04.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import CoreData
import UIKit

@UIApplicationMain
class AppDelegate : AbstractAppDelegate {

    var window: UIWindow?

    override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
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

    func application(_ app: UIApplication, openURL url: URL, options: [String : AnyObject]) -> Bool {
        if let target = XikoloURL.parseURL(url) {
            switch target.type {
                case .course:
                    var couldfindCourse = false
                    CoreDataHelper.viewContext.performAndWait {
                        let fetchRequest = CourseHelper.FetchRequest.course(withId: target.targetId)
                        switch CoreDataHelper.viewContext.fetchSingle(fetchRequest) {
                        case .success(let course):
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            let vc = storyboard.instantiateViewController(withIdentifier: "CourseDetailTabBarController") as! CourseTabBarController
                            vc.course = course
                            window?.rootViewController?.present(vc, animated: false, completion: nil)
                            couldfindCourse = true
                        case .failure(let error):
                            print("Warning: Could not find course")
                        }
                    }

                    if couldFindCourse {
                        return true
                    }

//                    if case let .success(course) = CoreDataHelper.fetchSingleObject(fetchRequest: fetchRequest, inContext: .view) {
//                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                        let vc = storyboard.instantiateViewController(withIdentifier: "CourseDetailTabBarController") as! CourseTabBarController
//                        vc.course = course
//                        window?.rootViewController?.present(vc, animated: false, completion: nil)
//                        return true
//                    }
            }
        }
        return false
    }

}
