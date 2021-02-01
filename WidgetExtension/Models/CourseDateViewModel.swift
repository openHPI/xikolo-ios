//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import Foundation

struct CourseDateViewModel {
    var courseTitle: String?
    var itemTitle: String?
    var date: Date?
//    var url: URL?
}

extension CourseDateViewModel {

    init(courseDate: CourseDate) {
        self.courseTitle = courseDate.course?.title
        self.itemTitle = courseDate.contextAwareTitle
        self.date = courseDate.date
    }

}
