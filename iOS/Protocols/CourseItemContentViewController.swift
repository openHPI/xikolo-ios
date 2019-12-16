//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common

protocol CourseItemContentPresenter: AnyObject {
    var item: CourseItem? { get }
    var additionalActions: [UIAlertAction] { get }
    func configure(for item: CourseItem)
}

extension CourseItemContentPresenter {

    var additionalActions: [UIAlertAction] { return [] }
    
}

typealias CourseItemContentViewController = CourseItemContentPresenter & UIViewController
