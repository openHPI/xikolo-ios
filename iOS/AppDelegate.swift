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

let log = Logger(subsystem: "de.xikolo.iOS", category: "iOS")

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    private let userProfileHelperDelegateInstance = UserProfileHelperDelegateInstance()

    private lazy var pushEngineManager: SyncPushEngineManager = {
        let engine = XikoloSyncEngine()
        return SyncPushEngineManager(syncEngine: engine)
    }()

    @available(iOS, obsoleted: 13.0)
    private lazy var tabBarController: UITabBarController = {
        let tabBarController = XikoloTabBarController.make()
        tabBarController.delegate = self
        return tabBarController
    }()

    @available(iOS, obsoleted: 13.0)
    lazy var appNavigator = AppNavigator(tabBarController: self.tabBarController)

    var window: UIWindow?

    private var shortcutItemToProcess: UIApplicationShortcutItem?

    static func instance() -> AppDelegate {
        let instance = UIApplication.shared.delegate as? AppDelegate
        return instance.require(hint: "Unable to find AppDelegate")
    }

    func setHomescreenQuickActions() {
        let fetchRequest = CourseHelper.FetchRequest.enrolledCurrentCoursesRequest
        let enrolledCurrentCourses = CoreDataHelper.viewContext.fetchMultiple(fetchRequest).value ?? []
        let subtitle = NSLocalizedString("quickactions.subtitle", comment: "subtitle for homescreen quick actions")

        UIApplication.shared.shortcutItems = enrolledCurrentCourses.map { enrolledCurrentCourses -> UIApplicationShortcutItem in
            return UIApplicationShortcutItem(type: "FavoriteAction",
                                             localizedTitle: enrolledCurrentCourses.title ?? "",
                                             localizedSubtitle: subtitle,
                                             icon: UIApplicationShortcutIcon(type: .bookmark),
                                             userInfo: ["courseID": enrolledCurrentCourses.id as NSSecureCoding]
            )
        }
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        if let shortcutItem = launchOptions?[UIApplication.LaunchOptionsKey.shortcutItem] as? UIApplicationShortcutItem {
            self.shortcutItemToProcess = shortcutItem
           }

        CoreDataHelper.migrateModelToCommon()
        UserProfileHelper.shared.logoutFromTestAccount()

        if #available(iOS 13.0, *) {} else {
            self.window = UIWindow(frame: UIScreen.main.bounds)
            self.window?.rootViewController = self.tabBarController
            self.window?.tintColor = Brand.default.colors.window
            self.window?.makeKeyAndVisible()

            // Select initial tab
            let tabToSelect: XikoloTabBarController.Tabs = UserProfileHelper.shared.isLoggedIn ? .dashboard : .courses
            self.tabBarController.selectedIndex = tabToSelect.index
        }

        DispatchQueue.main.async {
            // Configure Firebase
            FirebaseApp.configure()

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
        }

        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains("-cleanStatusBar") {
            log.info("Setup clean status bar")
            SDStatusBarManager.sharedInstance().enableOverrides()
        }
        #endif

        UICollectionView.enableEmptyStates()
        UITableView.enableEmptyStates()

        return true
    }

    @available(iOS, obsoleted: 13.0)
    func application(_ application: UIApplication,
                     continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        return self.appNavigator.handle(userActivity: userActivity)
    }

    @available(iOS, obsoleted: 13.0)
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return self.appNavigator.handle(url: url)
    }

    func applicationWillResignActive(_ application: UIApplication) {
        self.setHomescreenQuickActions()
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions
        // (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        self.shortcutItemToProcess = shortcutItem
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
        if let shortcutItem = self.shortcutItemToProcess {
            if #available(iOS 13.0, *) {} else {
                self.appNavigator.handle(shortcutItem: shortcutItem)
            }

            self.shortcutItemToProcess = nil
        }
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background,
        // optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        ReachabilityHelper.stopObserving()
        self.pushEngineManager.stopObserving()
        SpotlightHelper.shared.stopObserving()
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        log.info("Entered application configurationForConnecting connectingSceneSession")
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

}

@available(iOS, obsoleted: 13.0)
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

        tabBarController.present(loginNavigationController, animated: trueUnlessReduceMotionEnabled)

        return false
    }

}

@available(iOS, obsoleted: 13.0)
extension AppDelegate: LoginDelegate {

    func didSuccessfullyLogin() {
        self.tabBarController.selectedIndex = 0
    }

}
