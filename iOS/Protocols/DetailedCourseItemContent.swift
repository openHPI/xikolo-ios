//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation

protocol DetailedCourseItemContent {

    var detailedData: [DetailedDataItem] { get }

}

enum DetailedDataItem {

    case timeEffort(duration: TimeInterval)
    case slides
    case points(maxPoints: Double)

}
