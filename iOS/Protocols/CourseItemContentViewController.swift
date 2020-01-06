//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common

public protocol CourseItemContentPresenter: AnyObject {
    var item: CourseItem? { get }
    func configure(for item: CourseItem)
}

typealias CourseItemContentViewController = CourseItemContentPresenter & UIViewController
