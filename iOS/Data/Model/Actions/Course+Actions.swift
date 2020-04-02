//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common

extension Course {

    func shareAction(handler: @escaping () -> Void) -> Action {
        let title = NSLocalizedString("course.action-menu.share", comment: "Title for course item share action")
        return Action(title: title, image: Action.Image.share, handler: handler)
    }

    func showCourseDatesAction(handler: @escaping () -> Void) -> Action? {
        guard self.hasEnrollment && Brand.default.features.showCourseDatesOnDashboard else { return nil }
        let title = NSLocalizedString("course.action-menu.show-course-dates", comment: "Title for show course dates action")
        return Action(title: title, image: Action.Image.calendar, handler: handler)
    }

}
