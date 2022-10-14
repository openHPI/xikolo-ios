//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import Common
import UIKit

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
        guard self.offersNotificationsForNewContent else { return nil }
        let title = NSLocalizedString("automated-downloads.setup.action.title",
                                      comment: "Automated Downloads: Action title for managing notifications for new content")
        return Action(title: title, image: Action.Image.notification, handler: handler)
    }

    @available(iOS 13.0, *)
    var unenrollAction: UIAction? {
        guard let enrollment = self.enrollment else { return nil }
        let unenrollActionTitle = NSLocalizedString("enrollment.options-alert.unenroll-action.title",
                                                    comment: "title for unenroll action")
        return UIAction(title: unenrollActionTitle, image: Action.Image.unenroll, attributes: .destructive) { _ in
            EnrollmentHelper.delete(enrollment)
        }
    }

    @available(iOS 13.0, *)
    var markAsCompletedMenu: UIMenu? {
        // For this, we require the subtitle of the confirm action. The subtitle is only available on iOS 15 and later.
        guard #available(iOS 15, *) else { return nil }
        guard let enrollment = self.enrollment, !enrollment.completed else { return nil }

        let cancelActionTitle = NSLocalizedString("global.alert.cancel", comment: "title to cancel alert")
        let cancelAction = UIAction(title: cancelActionTitle, image: Action.Image.cancel) { _ in }

        let confirmActionTitle = NSLocalizedString("global.alert.ok", comment: "title to confirm alert")
        let confirmActionSubtitle = NSLocalizedString("enrollment.mark-as-completed.message.no-undo",
                                                      comment: "message for the mark as completed action that this action can not be undone")
        let markAsCompletedAction = UIAction(title: confirmActionTitle, subtitle: confirmActionSubtitle, image: Action.Image.ok) { _ in
            EnrollmentHelper.markAsCompleted(self)
        }

        let completedActionTitle = NSLocalizedString("enrollment.options-alert.mask-as-completed-action.title",
                                                     comment: "title for 'mask as completed' action")
        return UIMenu(title: completedActionTitle, image: Action.Image.markAsCompleted, children: [markAsCompletedAction, cancelAction])
    }

    @available(iOS 13.0, *)
    var manageEnrollmentMenu: UIMenu? {
        let enrollmentActions: [UIMenuElement] = [
            self.markAsCompletedMenu,
            self.unenrollAction,
        ].compactMap { $0 }

        if enrollmentActions.isEmpty {
            return nil
        } else {
            return UIMenu(title: "", options: .displayInline, children: enrollmentActions)
        }
    }

    var isEligibleForContentNotifications: Bool {
        guard #available(iOS 13, *) else { return false }
        guard self.hasEnrollment else { return false }
        guard self.endsAt?.inFuture ?? false else { return false }
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
