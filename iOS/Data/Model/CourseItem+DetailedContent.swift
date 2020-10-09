//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common

extension CourseItem {

    var detailedContent: [DetailedDataItem] {
        var data: [DetailedDataItem] = []

        if self.timeEffort > 0 {
            data.append(DetailedDataItem.timeEffort(duration: TimeInterval(self.timeEffort)))
        }

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

        if self.maxPoints > 0.0 {
            data.append(DetailedDataItem.points(maxPoints: self.maxPoints))
        }

        return data
    }

}
