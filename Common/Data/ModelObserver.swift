//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import CoreData
import Foundation

public final class ManagedObjectObserver {

    public enum ChangeType {
        case delete
        case update
    }

    public init?(object: NSManagedObject, changeHandler: @escaping (ChangeType) -> Void) {
        guard let moc = object.managedObjectContext else { return nil }
        self.objectHasBeenDeleted = NSPredicate(value: true).evaluate(with: object)
        self.token = moc.addObjectsDidChangeNotificationObserver { [weak self] note in
            guard let changeType = self?.changeType(of: object, in: note) else { return }
            self?.objectHasBeenDeleted = changeType == .delete
            changeHandler(changeType)
        }
    }

    deinit {
        guard let token =     self.token else { return }
        NotificationCenter.default.removeObserver(token)
    }

    // MARK: Private
    private var token: Any!
    private var objectHasBeenDeleted = false

    private func changeType(of object: NSManagedObject, in note: ObjectsDidChangeNotification) -> ChangeType? {
        let deleted = note.deletedObjects.union(note.invalidatedObjects)
        if note.invalidatedAllObjects || deleted.contains(where: { $0 == object }) {
            return .delete
        }

        let updated = note.updatedObjects.union(note.refreshedObjects)
        if updated.contains(where: { $0 == object }) {
            if NSPredicate(value: true).evaluate(with: object) {
                return .update
            } else if !self.objectHasBeenDeleted {
                return .delete
            }
        }

        return nil
    }
}
