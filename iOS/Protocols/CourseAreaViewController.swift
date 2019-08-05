//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import Foundation

protocol CourseAreaViewController: AnyObject {

    var area: CourseArea { get }

    func configure(for course: Course, with area: CourseArea, delegate: CourseAreaViewControllerDelegate)

}

protocol CourseAreaScrollDelegate: AnyObject {

    func scrollViewDidScroll(_ scrollView: UIScrollView)

}

protocol CourseAreaEnrollmentDelegate: AnyObject {

    func enrollmentStateDidChange(whenNewlyCreated newlyCreated: Bool)

}

typealias CourseAreaViewControllerDelegate = CourseAreaScrollDelegate & CourseAreaEnrollmentDelegate
