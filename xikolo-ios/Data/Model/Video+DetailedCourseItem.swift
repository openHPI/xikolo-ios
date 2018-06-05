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
            .stream(duration: TimeInterval(self.duration)),
        ]

        if self.slidesURL != nil {
            content.append(.slides)
        }

        return content
    }

}
