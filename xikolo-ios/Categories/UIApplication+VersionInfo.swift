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

    static let appName = {
        return Bundle.main.object(forInfoDictionaryKey: kCFBundleNameKey as String) as! String
    }()

    static let appVersion = {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    }()

    static let appBuild = {
        return Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as! String
    }()
}
