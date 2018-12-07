//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common

extension CourseItem {

    var detailedContent: [DetailedData] {
        var data = (self.content as? DetailedCourseItemContent)?.detailedContent ?? []
        if self.maxPoints > 0.0 {
            data.append(DetailedData.points(maxPoints: self.maxPoints))
        }

        return data
    }

}
