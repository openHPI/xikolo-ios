//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import Common
import UIKit

enum QuickActionHelper {

    static func setHomescreenQuickActions() {
        let fetchRequest = CourseHelper.FetchRequest.enrolledCurrentCoursesRequest
        let enrolledCurrentCourses = CoreDataHelper.viewContext.fetchMultiple(fetchRequest).value ?? []
        let subtitle = NSLocalizedString("quickactions.subtitle", comment: "subtitle for homescreen quick actions")

        UIApplication.shared.shortcutItems = enrolledCurrentCourses.map { enrolledCurrentCourses -> UIApplicationShortcutItem in
            return UIApplicationShortcutItem(type: "FavoriteAction",
                                             localizedTitle: enrolledCurrentCourses.title ?? "",
                                             localizedSubtitle: subtitle,
                                             icon: UIApplicationShortcutIcon(templateImageName: "rectangle.fill.badge.arrow.right"),
                                             userInfo: ["courseID": enrolledCurrentCourses.id as NSSecureCoding]
            )
        }
    }

}
