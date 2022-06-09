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

    func openHelpdeskAction(handler: @escaping () -> Void) -> Action {
        let title = NSLocalizedString("settings.cell-title.app-helpdesk", comment: "cell title for helpdesk")
        return Action(title: title, image: Action.Image.helpdesk, handler: handler)
    }

    func automatedDownloadAction(handler: @escaping () -> Void) -> Action? {
        guard self.offersNotificationsForNewContent || self.automatedDownloadSettings != nil else { return nil }
        let title = NSLocalizedString("automated-downloads.setup.action.title",
                                      comment: "Automated Downloads: Action title for managing notifications for new content")
        return Action(title: title, image: Action.Image.aggregatedDownload, handler: handler)
    }

    var isEligibleForContentNotifications: Bool {
        guard #available(iOS 13, *) else { return false }
        guard self.hasEnrollment else { return false }
        guard self.endsAt?.inFuture ?? false else { return false }
        guard self.sections.compactMap(\.startsAt?.inFuture).contains(true) else { return false }
        return true
    }

    var offersNotificationsForNewContent: Bool {
        guard self.isEligibleForContentNotifications else { return false }
        return FeatureHelper.hasFeature(.newContentNotification, for: self)
    }

    var offersAutomatedBackgroundDownloads: Bool {
        guard self.offersNotificationsForNewContent else { return false }
        return FeatureHelper.hasFeature(.newContentBackgroundDownload, for: self)
    }

}
