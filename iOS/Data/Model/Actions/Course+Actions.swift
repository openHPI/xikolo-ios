//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import Common

extension Course {

    func shareAction(handler: @escaping () -> Void) -> Action {
        let title = NSLocalizedString("course.action-menu.share", comment: "Title for course item share action")
        return Action(title: title, image: Action.Image.share, handler: handler)
    }

    func showCourseDatesAction(handler: @escaping () -> Void) -> Action? {
        guard self.hasEnrollment && Brand.default.features.showCourseDates else { return nil }
        let title = NSLocalizedString("course.action-menu.show-course-dates", comment: "Title for show course dates action")
        return Action(title: title, image: Action.Image.calendar, handler: handler)
    }

    func openHelpdesk(handler: @escaping () -> Void) -> Action {
        let title = NSLocalizedString("settings.cell-title.app-helpdesk", comment: "cell title for helpdesk")
        return Action(title: title, image: Action.Image.helpdesk, handler: handler)
    }

}
