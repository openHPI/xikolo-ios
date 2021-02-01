//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import UIKit

struct CourseViewModel {
    var title: String
    var itemTitle: String?
    var image: UIImage?
//    var url: URL?
}

extension CourseViewModel {

    init(course: Course) {
        self.title = course.title ?? "empty"
        self.itemTitle = "Continue learning"

        self.image = try? course.imageURL.map {
            try Data(contentsOf: $0)
        }.flatMap {
            UIImage(data: $0)
        }
    }

}
