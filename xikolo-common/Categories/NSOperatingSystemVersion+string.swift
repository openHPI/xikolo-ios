//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation

extension OperatingSystemVersion {

    func toString() -> String {
        return String(format: "%d.%d.%d", majorVersion, minorVersion, patchVersion)
    }

}
