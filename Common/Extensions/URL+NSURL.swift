//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import Foundation

extension URL {

    func asNSURL() -> NSURL? {
        return NSURL(string: self.absoluteString)
    }

}
