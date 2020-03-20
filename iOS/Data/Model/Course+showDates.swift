//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import Foundation

extension Course {

    public func showCourseDates(viewController: UIViewController) {

        let courseDatesViewController = R.storyboard.courseDates.instantiateInitialViewController().require()
        courseDatesViewController.course = self
        let navigationController = XikoloNavigationController(rootViewController: courseDatesViewController)
        navigationController.navigationBar.barTintColor = ColorCompatibility.systemBackground
        viewController.present(navigationController, animated: trueUnlessReduceMotionEnabled)

    }
}
