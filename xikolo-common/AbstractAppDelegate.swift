//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import CoreData
import UIKit

class AbstractAppDelegate : UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        CoreDataObserver.standard.startObserving()
        ReachabilityHelper.startObserving()
        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        CoreDataObserver.standard.stopObserving()
        ReachabilityHelper.stopObserving()
    }

}
