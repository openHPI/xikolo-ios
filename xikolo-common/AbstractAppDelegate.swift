//
//  AbstractAppDelegate.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 24.04.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import CoreData
import UIKit

class AbstractAppDelegate : UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        SyncHelper.standard.startObserving()
        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        CoreDataHelper.save(CoreDataHelper.viewContext)
        SyncHelper.standard.stopObserving()
    }

}
