//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import CoreData

extension Notification {

    public static var allCoreDataNotificationKeys: [String] {
        return [NSUpdatedObjectsKey, NSInsertedObjectsKey, NSDeletedObjectsKey, NSRefreshedObjectsKey]
    }

    public func includesChanges<T>(for type: T.Type, keys: [String] = Notification.allCoreDataNotificationKeys) -> Bool where T: NSManagedObject {
        return keys.map { key in
            guard let objects = self.userInfo?[key] as? Set<NSManagedObject>, !objects.isEmpty else { return false }
            return objects.contains { $0 is T }
        }.contains(true)
    }

}
