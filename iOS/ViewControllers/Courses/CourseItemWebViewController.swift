//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import Common
import Foundation

class CourseItemWebViewController: WebViewController {

    var courseItem: CourseItem! {
        didSet {
            self.url = self.courseItem.url
        }
    }

    private func setURL() {
        guard let courseId = self.courseItem.section?.course?.id else { return }
        guard let courseItemId = self.courseItem.base62id else { return }
        self.url = Routes.courses.appendingPathComponents([courseId, "items", courseItemId])
    }

}

extension CourseItemWebViewController: CourseItemContentPresenter {

    var item: CourseItem? {
        return self.courseItem
    }

    func configure(for item: CourseItem) {
        self.courseItem = item
    }

}
