//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation

extension URL {

    func asNSURL() -> NSURL? {
        return NSURL(string: self.absoluteString)
    }

}
