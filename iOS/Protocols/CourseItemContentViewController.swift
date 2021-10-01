//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import Common

public protocol CourseItemContentPresenter: AnyObject {

    var item: CourseItem? { get }

    func configure(for item: CourseItem)

}

typealias CourseItemContentViewController = CourseItemContentPresenter & UIViewController
