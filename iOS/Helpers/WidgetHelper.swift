//
//  Created for xikolo-ios under MIT license.
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
        let enrollmentsChanged = notification.includesChanges(for: Enrollment.self)

        if courseDatesChanged || coursesChanged || enrollmentsChanged {
            WidgetCenter.shared.reloadAllTimelines()
        }
    }

}
