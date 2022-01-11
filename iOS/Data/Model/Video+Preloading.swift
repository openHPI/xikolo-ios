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
        var detailedData = [
            DetailedDataItem.timeEffort(duration: TimeInterval(self.duration)),
        ]

        if self.slidesURL != nil {
            detailedData.append(.slides)
        }

        return detailedData
    }

}
