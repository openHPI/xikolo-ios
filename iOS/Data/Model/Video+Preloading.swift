//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import Common

extension Video: PreloadableCourseItemContent {

    static var contentType: String {
        return "video"
    }

}

extension Video: DetailedCourseItemContent {

    var detailedData: [DetailedDataItem] {
        var detailedData: [DetailedDataItem] = []

        if self.lastPosition > 0, self.lastPosition < TimeInterval(self.duration) {
            detailedData.append(.timeRemaining(duration: TimeInterval(self.duration) - self.lastPosition))
        } else {
            detailedData.append(.timeEffort(duration: TimeInterval(self.duration)))
        }

        if self.slidesURL != nil {
            detailedData.append(.slides)
        }

        return detailedData
    }

}
