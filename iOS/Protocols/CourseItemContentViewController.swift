//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common

protocol CourseItemContentViewController: AnyObject {
    func configure(for item: CourseItem)
    func prepareForCourseItemChange()
}

extension CourseItemContentViewController {
    func prepareForCourseItemChange() {}
}
