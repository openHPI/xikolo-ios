//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common

extension CourseItem {

    var detailedContent: [DetailedData] {
        return (self.content as? DetailedCourseItemContent)?.detailedContent ?? []
    }

}
