//
//  UIApplication+VersionInfo.swift
//  xikolo-ios
//
//  Created by Bjarne Sievers on 02.04.17.
//  Copyright © 2017 HPI. All rights reserved.
//  Inspired by http://stackoverflow.com/a/7608711/2387552
//

import UIKit

extension UIApplication {

    class func appVersion() -> String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    }

    class func appBuild() -> String {
        return Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as! String
    }

    class func versionBuild() -> String {
        let version = appVersion(), build = appBuild()
        return version == build ? "v\(version)" : "v\(version)(\(build))"
    }
}
