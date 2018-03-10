//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

extension UIApplication {

    //  Inspired by http://stackoverflow.com/a/7608711/2387552
    static let appName: String = {
        let key = kCFBundleNameKey as String
        let appName = Bundle.main.object(forInfoDictionaryKey: key) as? String
        return appName.require(hint: "Unable to retrieve bundle name")
    }()

    static let appVersion: String = {
        let key = "CFBundleShortVersionString"
        let appVersion = Bundle.main.object(forInfoDictionaryKey: key) as? String
        return appVersion.require(hint: "Unable to retrieve app version")
    }()

    static let appBuild: String = {
        let key = kCFBundleVersionKey as String
        let appBuild = Bundle.main.object(forInfoDictionaryKey: key) as? String
        return appBuild.require(hint: "Unable to retrieve build number")
    }()

}
