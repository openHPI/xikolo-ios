//
//  AbstractAppDelegate.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 24.04.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import CoreData
import UIKit
import XCGLogger

let log: XCGLogger = {
    let log = XCGLogger.default
    log.setup(level: .verbose, showThreadName: true, showLevel: true, showFileNames: true, showLineNumbers: true, writeToFile: nil)
    return log
}()

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
