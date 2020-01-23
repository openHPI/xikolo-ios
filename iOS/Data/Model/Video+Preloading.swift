//
//  Created for xikolo-ios under MIT license.
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
        return self.slidesURL != nil ? [.slides] : []
    }

}
