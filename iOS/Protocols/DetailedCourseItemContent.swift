//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import Foundation

protocol DetailedCourseItemContent {

    var detailedData: [DetailedDataItem] { get }

}

enum DetailedDataItem {

    case timeEffort(duration: TimeInterval)
    case timeRemaining(duration: TimeInterval)
    case slides
    case points(maxPoints: Double)

}

extension Array where Element == DetailedDataItem {
    var containsTimeRemaining: Bool {
        return self.map { value -> Bool in
            if case .timeRemaining = value {
                return true
            } else {
                return false
            }
        }.contains(true)
    }
}
