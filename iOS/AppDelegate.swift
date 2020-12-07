//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import Firebase
import FirebaseCrashlytics
import NotificationCenter
import UIKit

let logger = Logger(subsystem: "de.xikolo.iOS", category: "iOS")

@available(iOS 13, *)
private let notificationDelegate = XikoloNotificationDelegate()

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    private let userProfileHelperDelegateInstance = UserProfileHelperDelegateInstance()

    private lazy var pushEngineManager: SyncPushEngineManager = {
        return SyncPushEngineManager()
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

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if let shortcutItem = launchOptions?[UIApplication.LaunchOptionsKey.shortcutItem] as? UIApplicationShortcutItem {
            self.shortcutItemToProcess = shortcutItem
        }

        CoreDataHelper.migrateModelToCommon()
        UserProfileHelper.shared.logoutFromTestAccount()
        UserProfileHelper.shared.migrateLegacyKeychain()
        UserProfileHelper.shared.migrateToSharedKeychain()

        // Disable today widget on home screen if course dates are not displayed
        if let bundleId = Bundle.main.bundleIdentifier?.appending(".today") {
            let hasContent = Brand.default.features.showCourseDates
            NCWidgetController().setHasContent(hasContent, forWidgetWithBundleIdentifier: bundleId)
        }

        if #available(iOS 13.0, *) {} else {
            self.window = UIWindow(frame: UIScreen.main.bounds)
            self.window?.rootViewController = self.tabBarController
            self.window?.tintColor = Brand.default.colors.window
            self.window?.makeKeyAndVisible()

            // Select initial tab
            let tabToSelect: XikoloTabBarController.Tabs = UserProfileHelper.shared.isLoggedIn ? .dashboard : .courses
            self.tabBarController.selectedIndex = tabToSelect.index
        }

        if Brand.default.features.showCourseDates {
            UIApplication.shared.setMinimumBackgroundFetchInterval(86400) // approx. every 24 hours
        }

        DispatchQueue.main.async {
            // Configure Firebase
            FirebaseApp.configure()

            UserProfileHelper.shared.delegate = self.userProfileHelperDelegateInstance

            ErrorManager.shared.register(reporter: Crashlytics.crashlytics())

            // register resource to be pushed automatically
            self.pushEngineManager.register(Announcement.self)
            self.pushEngineManager.register(CourseItem.self)
            self.pushEngineManager.register(Enrollment.self)
            self.pushEngineManager.register(TrackingEvent.self, with: .nonExpensive)
            self.pushEngineManager.startObserving()

            StreamPersistenceManager.shared.restoreDownloads()
            SlidesPersistenceManager.shared.restoreDownloads()

            SpotlightHelper.shared.startObserving()

            do {
                try ReachabilityHelper.startObserving()
            } catch {
                ErrorManager.shared.report(error)
                logger.error("Failed to start reachability notification")
            }

            if #available(iOS 13.0, *) {
                UNUserNotificationCenter.current().delegate = notificationDelegate
                XikoloNotification.setNotificationCategories()
                AutomatedDownloadsManager.registerBackgroundTask()
            }
        }

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
        QuickActionHelper.setHomescreenQuickActions()
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

    func application(_ application: UIApplication,
                     performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        guard Brand.default.features.showCourseDates && UserProfileHelper.shared.isLoggedIn else {
            completionHandler(.noData)
            return
        }

        CourseHelper.syncAllCourses().flatMap { _ in
            return CourseDateHelper.syncAllCourseDates()
        }.onSuccess { syncResult in
            let newData = Set(syncResult.oldObjectIds) != Set(syncResult.newObjectIds)
            let backgroundFetchResult: UIBackgroundFetchResult = newData ? .newData : .noData
            completionHandler(backgroundFetchResult)
        }.onFailure { _ in
            completionHandler(.failed)
        }
    }

    func application(_ application: UIApplication,
                     handleEventsForBackgroundURLSession identifier: String,
                     completionHandler: @escaping () -> Void) {
        if StreamPersistenceManager.shared.session.configuration.identifier == identifier {
            StreamPersistenceManager.shared.backgroundCompletionHandler = completionHandler
        } else if SlidesPersistenceManager.shared.session.configuration.identifier == identifier {
            SlidesPersistenceManager.shared.backgroundCompletionHandler = completionHandler
        } else if DocumentsPersistenceManager.shared.session.configuration.identifier == identifier {
            DocumentsPersistenceManager.shared.backgroundCompletionHandler = completionHandler
        } else if #available(iOS 13, *), AutomatedDownloadsManager.urlSessionIdentifier == identifier {
            AutomatedDownloadsManager.backgroundCompletionHandler = completionHandler
        }
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        logger.info("Entered application configurationForConnecting connectingSceneSession")

        if options.userActivities.first?.activityType == Bundle.main.activityTypeOpenCourse {
            return UISceneConfiguration(name: "Course Configuration", sessionRole: connectingSceneSession.role)
        } else {
            return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
        }
    }

}

@available(iOS, obsoleted: 13.0)
extension AppDelegate: UITabBarControllerDelegate {

    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        guard !UserProfileHelper.shared.isLoggedIn else {
            return true
        }

        guard let navigationController = viewController as? UINavigationController else {
            logger.info("Navigation controller not found")
            return true
        }

        guard navigationController.viewControllers.first is DashboardViewController else {
            return true
        }

        self.appNavigator.presentDashboardLoginViewController()
        return false
    }

}
