//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Firebase
import SDWebImage
import UIKit

#if DEBUG
import SimulatorStatusMagic
#endif

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    class func instance() -> AppDelegate {
        let instance = UIApplication.shared.delegate as? AppDelegate
        return instance.require(hint: "Unable to find AppDelegate")
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        self.window?.tintColor = Brand.default.colors.window

        // select start tab
        self.tabBarController?.selectedIndex = UserProfileHelper.isLoggedIn ? 0 : 1
        if UserProfileHelper.isLoggedIn {
            CourseHelper.syncAllCourses().onComplete { _ in
                CourseDateHelper.syncAllCourseDates()
            }
        }

        // register tab bar delegate
        self.tabBarController?.delegate = self

        // Configure Firebase
        FirebaseApp.configure()

        // register resource to be pushed automatically
        SyncPushEngine.shared.register(Announcement.self)
        SyncPushEngine.shared.register(CourseItem.self)
        SyncPushEngine.shared.register(Enrollment.self)
        SyncPushEngine.shared.register(TrackingEvent.self)
        SyncPushEngine.shared.check()

        UserProfileHelper.migrateLegacyKeychain()

        StreamPersistenceManager.shared.restoreDownloads()
        SlidesPersistenceManager.shared.restoreDownloads()

        CoreDataObserver.standard.startObserving()
        ReachabilityHelper.startObserving()

        if Brand.default.useDummyCredentialsForSDWebImage {
            // The openSAP backend uses a special certificate, which lets SDWebImage to cancel the requests.
            // By setting 'username' and 'password', a dummy certificate is created that allows the request
            // of SDWebImage to pass.
            // See 'SDWebImageDownloaderOperation.urlSession(_:task:didReceive:completionHandler:)'
            // SDWebImage (ver. 4.0.0) -> SDWebImageDownloaderOperation -> Line 408
            SDWebImageDownloader.shared().username = "open"
            SDWebImageDownloader.shared().password = "SAP"
        }

        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains("-cleanStatusBar") {
            log.info("Setup clean status bar")
            SDStatusBarManager.sharedInstance().enableOverrides()
        }
        #endif

        return true
    }

    func application(_ application: UIApplication,
                     continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        return AppNavigator.handle(userActivity: userActivity, forApplication: application, on: self.tabBarController)
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions
        // (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        UserDefaults.standard.synchronize()
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore
        // your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background,
        // optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        CoreDataObserver.standard.stopObserving()
        ReachabilityHelper.stopObserving()
    }

    var tabBarController: UITabBarController? {
        guard let tabBarController = self.window?.rootViewController as? UITabBarController else {
            log.warning("UITabBarController could not be found")
            return nil
        }

        return tabBarController
    }

}

extension AppDelegate: UITabBarControllerDelegate {

    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        guard !UserProfileHelper.isLoggedIn else {
            return true
        }

        guard let navigationController = viewController as? UINavigationController else {
            log.info("Navigation controller not found")
            return true
        }

        guard navigationController.viewControllers.first is CourseDatesListViewController else {
            return true
        }

        guard let loginNavigationController = R.storyboard.login.instantiateInitialViewController() else {
            let reason = "Initial view controller of Login stroyboard in not of type UINavigationController"
            CrashlyticsHelper.shared.recordCustomExceptionName("Storyboard Error", reason: reason, frameArray: [])
            log.error(reason)
            return false
        }

        guard let loginViewController = loginNavigationController.viewControllers.first as? LoginViewController else {
            let reason = "Could not find LoginViewController"
            CrashlyticsHelper.shared.recordCustomExceptionName("Storyboard Error", reason: reason, frameArray: [])
            log.error(reason)
            return false
        }

        loginViewController.delegate = self

        tabBarController.present(loginNavigationController, animated: true)

        return false
    }

}

extension AppDelegate: LoginDelegate {

    func didSuccessfullyLogin() {
        self.tabBarController?.selectedIndex = 0
    }
}
