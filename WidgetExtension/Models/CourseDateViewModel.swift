//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import Common
import Foundation

struct CourseDateViewModel {

    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()

    var courseTitle: String?
    var itemTitle: String
    var date: Date
    var url: URL?

    var formattedFullDate: String {
        return Self.dateFormatter.string(from: date)
    }

}

extension CourseDateViewModel {

    init(courseDate: CourseDate) {
        self.courseTitle = courseDate.course?.title
        self.itemTitle = courseDate.contextAwareTitle
        self.date = courseDate.date ?? Date()
        self.url = courseDate.course?.url
    }

}
