//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

var trueUnlessReduceMotionEnabled: Bool {
    return !UIAccessibility.isReduceMotionEnabled
}

// swiftlint:disable:next identifier_name
var defaultAnimationDurationUnlessReduceMotionEnabled: TimeInterval {
    return trueUnlessReduceMotionEnabled ? 0.25 : 0.0
}
