//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common

protocol CourseItemContentViewController: AnyObject {
    var item: CourseItem? { get }

    func configure(for item: CourseItem)
}
