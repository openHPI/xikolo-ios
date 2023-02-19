//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import Common
import UserNotifications

@available(iOS 13, *)
enum QuizRecapNotificationManager {

    static func renewNotifications(for course: Course) {
        self.renewSectionNotifications(for: course)
        self.renewCourseEndNotification(for: course)
    }

    private static func renewSectionNotifications(for course: Course) {
        let center = UNUserNotificationCenter.current()

        let identifiersForPendingRequests = course.sections.map(XikoloNotification.RequestIdentifier.identifierForQuizRecap(for:))
        center.removePendingNotificationRequests(withIdentifiers: identifiersForPendingRequests)

        guard FeatureHelper.hasFeature(.quizRecapSectionNotifications, for: course) else { return }

        let sectionStartDates = course.sections.map(\.startsAt)
        let possibleStartDates = (sectionStartDates + [course.endsAt]).compactMap({ $0 })

        for section in course.sections {
            guard section.containsItemsForQuizRecap else { continue }
            let startDate = section.startsAt ?? course.startsAt ?? Date()
            let nextSectionStartDate = possibleStartDates.filter { $0 > startDate }.min()
            guard let request = XikoloNotification.sectionRecapNotificationRequest(for: section, withNextSectionStart: nextSectionStartDate) else { continue }
            center.add(request)
        }
    }

    private static func renewCourseEndNotification(for course: Course) {
        let center = UNUserNotificationCenter.current()

        let identifiersForPendingRequest = XikoloNotification.RequestIdentifier.identifierForQuizRecap(for: course)
        center.removePendingNotificationRequests(withIdentifiers: [identifiersForPendingRequest])

        guard FeatureHelper.hasFeature(.quizRecapCourseEndNotification, for: course) else { return }

        guard course.sections.contains(where: { $0.containsItemsForQuizRecap }) else { return }

        let lastSectionStartDate = course.sections.compactMap(\.startsAt).max()
        guard let request = XikoloNotification.courseRecapNotificationRequest(for: course, withExamStart: lastSectionStartDate) else { return }
        center.add(request)
    }

}
