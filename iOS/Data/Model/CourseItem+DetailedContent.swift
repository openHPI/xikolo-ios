//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import Common

extension CourseItem {

    var detailedContent: [DetailedDataItem] {
        var data: [DetailedDataItem] = []

        if let detailedContent = self.content as? DetailedCourseItemContent {
            data += detailedContent.detailedData.filter {
                // Don't include time effort twice
                if case .timeEffort = $0 {
                    return !(self.timeEffort > 0)
                } else {
                    return true
                }
            }
        }

        if self.timeEffort > 0, !data.containsTimeRemaining {
            data.insert(DetailedDataItem.timeEffort(duration: TimeInterval(self.timeEffort)), at: 0)
        }

        if self.maxPoints > 0.0 {
            data.append(DetailedDataItem.points(maxPoints: self.maxPoints))
        }

        return data
    }

}
