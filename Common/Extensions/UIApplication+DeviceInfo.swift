//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

extension UIApplication {

    public static let platform = UIDevice.current.systemName

    public static let osVersion: String = {
        let version = ProcessInfo().operatingSystemVersion
        return String(format: "%d.%d.%d", version.majorVersion, version.minorVersion, version.patchVersion)
    }()

    public static let device: String = {
        #if targetEnvironment(simulator)
        return "Simulator"
        #else
        var sysinfo = utsname()
        uname(&sysinfo)
        return withUnsafeMutablePointer(to: &sysinfo.machine) { ptr in
            String(cString: UnsafeRawPointer(ptr).assumingMemoryBound(to: CChar.self))
        }
        #endif
    }()

}
