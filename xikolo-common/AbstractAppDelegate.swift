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

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        return true
    }

    func applicationWillTerminate(application: UIApplication) {
        CoreDataHelper.saveContext()
    }

}
