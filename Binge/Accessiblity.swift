//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

var trueUnlessReduceMotionEnabled: Bool {
    return !UIAccessibility.isReduceMotionEnabled
}
