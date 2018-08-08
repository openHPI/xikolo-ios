//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import Foundation

protocol CourseAreaViewController {
    func configure(for course: Course, delegate: CourseAreaViewControllerDelegate)
}

protocol CourseAreaViewControllerDelegate {
    func enrollmentStateDidChange()
}
