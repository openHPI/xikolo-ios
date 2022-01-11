//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import Common
import CoreData
import Foundation
import UIKit
import WidgetKit

class WidgetHelper {

    static let shared = WidgetHelper()

    private init() {}

    func startObserving() {
        if #available(iOS 14.0, *) {
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(coreDataChange(notification:)),
                                                   name: NSNotification.Name.NSManagedObjectContextObjectsDidChange,
                                                   object: CoreDataHelper.viewContext)
        }
    }

    func stopObserving() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: CoreDataHelper.viewContext)
    }

    @available(iOS 14, *)
    @objc private func coreDataChange(notification: Notification) {
        let courseDatesChanged = notification.includesChanges(for: CourseDate.self)
        let coursesChanged = notification.includesChanges(for: Course.self)
        let enrollmentsRefreshed = notification.includesChanges(for: Enrollment.self, key: .refreshed)
        let lastVisitChanged = notification.includesChanges(for: LastVisit.self)

        // WidgetCenter cannot be used on armv7
        // (can be removed when support for iOS 10 was dropped)
        #if arch(arm64) || arch(i386) || arch(x86_64)
        if courseDatesChanged || coursesChanged || enrollmentsRefreshed {
            let widgetKinds = ["course-date-overview", "course-date-next", "course-date-statistics"]
            widgetKinds.forEach { WidgetCenter.shared.reloadTimelines(ofKind: $0) }
        }

        if coursesChanged || enrollmentsRefreshed || lastVisitChanged {
            WidgetCenter.shared.reloadTimelines(ofKind: "continue-learning")
        }
        #endif
    }

}
