//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation

protocol DetailedCourseItemContent {

    var detailedContent: [DetailedData] { get }

}

enum DetailedData {

    case text(readingTime: TimeInterval)
    case stream(duration: TimeInterval)
    case slides

}
