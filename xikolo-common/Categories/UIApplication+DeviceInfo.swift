//
//  UIApplication+DeviceInfo.swift
//  openHPI-iOS
//
//  Created by Max Bothe on 21.08.17.
//  Copyright © 2017 HPI. All rights reserved.
//

import UIKit

extension UIApplication {

    #if os(tvOS)
    static let platform = "tvOS"
    #else
    static let platform = "iOS"
    #endif

    static let osVersion: String = {
        return ProcessInfo().operatingSystemVersion.toString()
    }()

    static let device: String = {
        var sysinfo = utsname()
        uname(&sysinfo)
        var name = withUnsafeMutablePointer(to: &sysinfo.machine) { ptr in
            String(cString: UnsafeRawPointer(ptr).assumingMemoryBound(to: CChar.self))
        }
        if ["i386", "x86_64"].contains(name) {
            name = "Simulator"
        }
        return name
    }()

}
