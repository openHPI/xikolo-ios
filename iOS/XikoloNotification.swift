//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import Common
import UIKit
import UserNotifications

enum XikoloNotification {

    enum CategoryIdentifier {
        static let newContent = "XikoloNewContentCategory"
        static let quizRecapForSection = "XikoloQuizRecapSectionCategory"
        static let quizRecapForCourse = "XikoloQuizRecapCourseCategory"
    }

    enum ActionIdentifier {
        static let download = "XikoloDownload"
    }

    enum RequestIdentifier {
        static func identifierForNewContent(for section: CourseSection) -> String {
            return "new-content-section-\(section.id)"
        }

        static func identifierForQuizRecap(for section: CourseSection) -> String {
            return "quiz-recap-section-\(section.id)"
        }

        static func identifierForQuizRecap(for course: Course) -> String {
            return "quiz-recap-course-\(course.id)"
        }
    }

    static func setNotificationCategories() {
        let center = UNUserNotificationCenter.current()
        let categories = [
            self.categoriesForNewContentNotifications(),
            self.categoriesFoRecapNotifications(),
        ].reduce(into: Set()) { partialResult, category in
            partialResult.formUnion(category)
        }
        center.setNotificationCategories(categories)
    }

    static func categoriesForNewContentNotifications() -> Set<UNNotificationCategory> {
        let title = NSString.localizedUserNotificationString(forKey: "notification.new-content.action.download", arguments: nil)
        let downloadAction = UNNotificationAction(identifier: ActionIdentifier.download, title: title, options: [])
        let category = UNNotificationCategory(identifier: CategoryIdentifier.newContent, actions: [downloadAction], intentIdentifiers: [])
        return [category]
    }

    static func categoriesFoRecapNotifications() -> Set<UNNotificationCategory> {
        return [
            UNNotificationCategory(identifier: CategoryIdentifier.quizRecapForSection, actions: [], intentIdentifiers: []),
            UNNotificationCategory(identifier: CategoryIdentifier.quizRecapForCourse, actions: [], intentIdentifiers: []),
        ]
    }

    static func sectionStartNotificationRequest(for section: CourseSection) -> UNNotificationRequest? {
        guard let sectionStart = section.startsAt, sectionStart.inFuture else { return nil }

        let identifier = Self.RequestIdentifier.identifierForNewContent(for: section)

        let content = UNMutableNotificationContent()
        content.title = section.course?.title ?? UIApplication.appName
        let sectionTitle = section.title ?? String(section.position)
        content.body = NSString.localizedUserNotificationString(forKey: "notification.new-content.body", arguments: [sectionTitle])
        content.categoryIdentifier = self.CategoryIdentifier.newContent
        content.userInfo = ["section-id": section.id]

        let dateComponents = Calendar.autoupdatingCurrent.dateComponents(
            [.year, .month, .day, .hour, .minute, .timeZone],
            from: sectionStart.addingTimeInterval(2 * 60) // 2 minutes after section start
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)

        return UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
    }

    static func sectionRecapNotificationRequest(for section: CourseSection, withNextSectionStart nextSectionStart: Date?) -> UNNotificationRequest? {
        guard let nextSectionStart = nextSectionStart else { return nil }

        let calendar = Calendar.autoupdatingCurrent
        let notificationDate = calendar.date(byAdding: .day, value: -2, to: nextSectionStart) ?? nextSectionStart.addingTimeInterval(-2 * 60 * 60 * 24)

        guard notificationDate.inFuture else { return nil }

        let identifier = Self.RequestIdentifier.identifierForQuizRecap(for: section)

        let content = UNMutableNotificationContent()
        content.title = section.course?.title ?? UIApplication.appName
        let sectionTitle = section.title ?? String(section.position)
        content.body = NSString.localizedUserNotificationString(forKey: "notification.quiz-recap-section.body", arguments: [sectionTitle])
        content.categoryIdentifier = self.CategoryIdentifier.quizRecapForSection
        content.userInfo = ["section-id": section.id]

        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .timeZone], from: notificationDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)

        return UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
    }

    static func courseRecapNotificationRequest(for course: Course, withExamStart examStart: Date?) -> UNNotificationRequest? {
        guard let examStart = examStart, examStart.inFuture else { return nil }

        let identifier = Self.RequestIdentifier.identifierForQuizRecap(for: course)

        let content = UNMutableNotificationContent()
        content.title = course.title ?? UIApplication.appName
        content.body = NSString.localizedUserNotificationString(forKey: "notification.quiz-recap-course.body", arguments: [])
        content.categoryIdentifier = self.CategoryIdentifier.quizRecapForCourse
        content.userInfo = ["course-id": course.id]

        let calendar = Calendar.autoupdatingCurrent
        let notificationDate = examStart.addingTimeInterval(2 * 60)
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .timeZone], from: notificationDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)

        return UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
    }

}
