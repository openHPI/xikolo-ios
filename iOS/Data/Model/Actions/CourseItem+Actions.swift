//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common

extension CourseItem {

    func shareAction(handler: @escaping () -> Void) -> Action {
        let title = NSLocalizedString("course.action-menu.share", comment: "Title for course item share action")
        return Action(title: title, image: Action.Image.share, handler: handler)
    }

    func openHelpdesk(handler: @escaping () -> Void) -> Action {
        let title = NSLocalizedString("settings.cell-title.app-helpdesk", comment: "cell title for helpdesk")
        return Action(title: title, image: Action.Image.helpdesk, handler: handler)
    }

}
