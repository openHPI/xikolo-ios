//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import UIKit

var trueUnlessReduceMotionEnabled: Bool {
    return !UIAccessibility.isReduceMotionEnabled
}

let defaultAnimationDuration: TimeInterval = 0.25

func defaultAnimationDuration(_ animated: Bool) -> TimeInterval {
    return animated ? defaultAnimationDuration : 0.0
}

// swiftlint:disable:next identifier_name
var defaultAnimationDurationUnlessReduceMotionEnabled: TimeInterval {
    return trueUnlessReduceMotionEnabled ? defaultAnimationDuration : 0.0
}

func defaultAnimationDurationUnlessReduceMotionEnabled(_ animated: Bool) -> TimeInterval {
    return animated ? defaultAnimationDurationUnlessReduceMotionEnabled : 0.0
}
