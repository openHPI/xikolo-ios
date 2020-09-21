//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import CoreData

extension Notification {

    public enum CoreDataNotificationKey: CaseIterable {
        case updated
        case inserted
        case deleted
        case refreshed

        var keyName: String {
            switch self {
            case .updated:
                return NSUpdatedObjectsKey
            case .inserted:
                return NSInsertedObjectsKey
            case .deleted:
                return NSDeletedObjectsKey
            case .refreshed:
                return NSRefreshedObjectsKey
            }
        }
    }

    public func includesChanges<T>(for type: T.Type, key: CoreDataNotificationKey) -> Bool where T: NSManagedObject {
        guard let objects = self.userInfo?[key.keyName] as? Set<NSManagedObject>, !objects.isEmpty else { return false }
        return objects.contains { $0 is T }
    }

    public func includesChanges<T>(for type: T.Type, keys: [CoreDataNotificationKey] = CoreDataNotificationKey.allCases) -> Bool where T: NSManagedObject {
        return keys.map { key in
            return self.includesChanges(for: type, key: key)
        }.contains(true)
    }

}
