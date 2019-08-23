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

    var window: UIWindow?

    static func instance() -> AppDelegate {
        let instance = UIApplication.shared.delegate as? AppDelegate
        return instance.require(hint: "Unable to find AppDelegate")
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        CoreDataHelper.migrateModelToCommon()

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

        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains("-cleanStatusBar") {
            log.info("Setup clean status bar")
            SDStatusBarManager.sharedInstance().enableOverrides()
        }
        #endif

        return true
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
    
    @available(iOS 13.0, *)
    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        log.info("Entered application configurationForConnecting connectingSceneSession")
        return UISceneConfiguration(name: "Default Configuration",
                                    sessionRole: connectingSceneSession.role)
    }

}
