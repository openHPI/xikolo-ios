//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

extension UIApplication {

    public static let bundleIdentifier: String = {
        return Bundle.main.bundleIdentifier.require(hint: "Unable to retrieve bundle identifier")
    }()

    //  Inspired by http://stackoverflow.com/a/7608711/2387552
    public static let bundleName: String = {
        let bundleNameKey = kCFBundleNameKey as String
        let bundleName = Bundle.main.object(forInfoDictionaryKey: bundleNameKey) as? String
        return bundleName.require(hint: "Unable to retrieve bundle name")
    }()

    public static let appName: String = {
        let bundleDisplayNameKey = "CFBundleDisplayName"
        if let localizedAppName = Bundle.main.infoDictionary?[bundleDisplayNameKey] as? String {
            return localizedAppName
        } else {
            let bundleNameKey = kCFBundleNameKey as String
            let bundleName = Bundle.main.object(forInfoDictionaryKey: bundleNameKey) as? String
            return bundleName.require(hint: "Unable to retrieve bundle name")
        }
    }()

    public static let appVersion: String = {
        let key = "CFBundleShortVersionString"
        let appVersion = Bundle.main.object(forInfoDictionaryKey: key) as? String
        return appVersion.require(hint: "Unable to retrieve app version")
    }()

    public static let appBuild: String = {
        let key = kCFBundleVersionKey as String
        let appBuild = Bundle.main.object(forInfoDictionaryKey: key) as? String
        return appBuild.require(hint: "Unable to retrieve build number")
    }()

}
