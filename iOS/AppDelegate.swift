//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import Crashlytics
import Firebase
import SDWebImage
import UIKit

#if DEBUG
import SimulatorStatusMagic
#endif

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    private let userProfileHelperDelegateInstance = UserProfileHelperDelegateInstance()

    private lazy var pushEngineManager: SyncPushEngineManager = {
        let engine = XikoloSyncEngine()
        return SyncPushEngineManager(syncEngine: engine)
    }()

    var window: UIWindow?

    class func instance() -> AppDelegate {
        let instance = UIApplication.shared.delegate as? AppDelegate
        return instance.require(hint: "Unable to find AppDelegate")
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        self.window?.tintColor = Brand.default.colors.window

        CoreDataHelper.migrateModelToCommon()

        // select start tab
        self.tabBarController?.selectedIndex = UserProfileHelper.shared.isLoggedIn ? 0 : 1
        if UserProfileHelper.shared.isLoggedIn {
            CourseHelper.syncAllCourses().onComplete { _ in
                CourseDateHelper.syncAllCourseDates()
            }
        }

        // Configure Firebase
        FirebaseApp.configure()

        // register tab bar delegate
        self.tabBarController?.delegate = self

        TrackingHelper.shared.delegate = self
        AnnouncementHelper.shared.delegate = self
        UserProfileHelper.shared.delegate = self.userProfileHelperDelegateInstance

        ErrorManager.shared.register(reporter: Crashlytics.sharedInstance())

        // register resource to be pushed automatically
        self.pushEngineManager.register(Announcement.self)
        self.pushEngineManager.register(CourseItem.self)
        self.pushEngineManager.register(Enrollment.self)
        self.pushEngineManager.register(TrackingEvent.self)
        self.pushEngineManager.startObserving()

        UserProfileHelper.shared.migrateLegacyKeychain()

        StreamPersistenceManager.shared.restoreDownloads()
        SlidesPersistenceManager.shared.restoreDownloads()

        SpotlightHelper.shared.startObserving()

        do {
            try ReachabilityHelper.startObserving()
        } catch {
            ErrorManager.shared.report(error)
            log.error("Failed to start reachability notification")
        }

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
        return AppNavigator.handle(userActivity: userActivity)
    }

    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return AppNavigator.handle(url: url)
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
        ReachabilityHelper.stopObserving()
        self.pushEngineManager.stopObserving()
        SpotlightHelper.shared.stopObserving()
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
        guard !UserProfileHelper.shared.isLoggedIn else {
            return true
        }

        guard let navigationController = viewController as? UINavigationController else {
            log.info("Navigation controller not found")
            return true
        }

        guard navigationController.viewControllers.first is DashboardViewController else {
            return true
        }

        guard let loginNavigationController = R.storyboard.login.instantiateInitialViewController() else {
            let reason = "Initial view controller of Login stroyboard in not of type UINavigationController"
            ErrorManager.shared.reportStoryboardError(reason: reason)
            log.error(reason)
            return false
        }

        guard let loginViewController = loginNavigationController.viewControllers.first as? LoginViewController else {
            let reason = "Could not find LoginViewController"
            ErrorManager.shared.reportStoryboardError(reason: reason)
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

extension AppDelegate: AnnouncementHelperDelegate {

    func updateUnreadAnnouncementsBadge() {
        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains("-cleanTabBar") {
            log.info("Don't show badge when making screenshots")
            return
        }
        #endif

        DispatchQueue.main.async {
            guard let tabItem = self.tabBarController?.tabBar.items?[safe: 2] else {
                log.warning("Failed to retrieve tab item for announcements")
                return
            }

            guard UserProfileHelper.shared.isLoggedIn else {
                tabItem.badgeValue = nil
                return
            }

            CoreDataHelper.persistentContainer.performBackgroundTask { context in
                let fetchRequest = AnnouncementHelper.FetchRequest.unreadAnnouncements
                do {
                    let announcementCount = try context.count(for: fetchRequest)
                    let badgeValue = announcementCount > 0 ? String(describing: announcementCount) : nil
                    DispatchQueue.main.async {
                        tabItem.badgeValue = badgeValue
                    }
                } catch {
                    log.warning("Failed to retrieve unread announcement count")
                }
            }
        }
    }

}

extension AppDelegate: TrackingHelperDelegate {

    var applicationWindowSize: CGSize? {
        return self.window?.frame.size
    }

}
