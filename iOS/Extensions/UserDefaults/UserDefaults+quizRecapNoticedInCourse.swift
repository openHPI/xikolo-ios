//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import Common
import Foundation

extension UserDefaults {

    private static let quizRecapNoticedInCourseKeyFormat = "de.xikolo.ios.quiz-recap.noticed-promo.%@"
    static let quizRecapNoticedNotificationName = Notification.Name("quiz-recap-noticed")

    private func quizRecapNoticedKey(for course: Course) -> String {
        return String(format: Self.quizRecapNoticedInCourseKeyFormat, course.id)
    }

    func wasQuizRecapNoticed(in course: Course) -> Bool {
        let key = self.quizRecapNoticedKey(for: course)
        return self.bool(forKey: key)
    }

    func setQuizRecapNoticed(to value: Bool, in course: Course) {
        let key = self.quizRecapNoticedKey(for: course)
        self.set(value, forKey: key)
    }

}
