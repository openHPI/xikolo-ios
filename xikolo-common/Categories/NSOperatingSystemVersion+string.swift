//
//  NSOperatingSystemVersion+string.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 30.08.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import Foundation

extension NSOperatingSystemVersion {

    func toString() -> String {
        return String(format: "%d.%d.%d", majorVersion, minorVersion, patchVersion)
    }

}
