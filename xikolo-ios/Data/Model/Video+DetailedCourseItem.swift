//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures
import CoreData
import Foundation

extension Video: DetailedCourseItem {

    static var contentType: String {
        return "video"
    }

    var detailedContent: [DetailedData] {
        var content: [DetailedData] = [
            .video(duration: TimeInterval(self.duration), downloaded: self.localFileBookmark != nil),
        ]

        if self.slidesURL != nil {
            content.append(.slides(downloaded: false))
        }

        return content
    }

}
