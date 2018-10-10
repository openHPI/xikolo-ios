//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import Foundation

protocol CourseAreaViewController: AnyObject {
    func configure(for course: Course, delegate: CourseAreaViewControllerDelegate)
}

protocol CourseAreaViewControllerDelegate: AnyObject {

    var currentArea: CourseArea? { get }

    func enrollmentStateDidChange(whenNewlyCreated newlyCreated: Bool)

}
