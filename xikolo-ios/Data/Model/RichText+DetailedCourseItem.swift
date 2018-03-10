//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation
import CoreData
import BrightFutures

extension RichText: DetailedCourseItem {

    static var contentType: String {
        return "rich_text"
    }

    var detailedContent: [DetailedData] {
        let words = self.text?.components(separatedBy: CharacterSet.whitespacesAndNewlines)
        guard let wordcount = words?.count else {
            return []
        }

        let approximatedReadingTime = ceil(Double(wordcount) / 200) * 60
        return [.text(readingTime: approximatedReadingTime)]
    }

    static func preloadContentFor(course: Course) -> Future<SyncEngine.SyncMultipleResult, XikoloError> {
        return CourseItemHelper.syncRichTexts(forCourse: course)
    }

}
