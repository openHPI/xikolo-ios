//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import CoreData

public struct ObjectsDidChangeNotification {

    init(note: Notification) {
        assert(note.name == .NSManagedObjectContextObjectsDidChange)
        self.notification = note
    }

    public var insertedObjects: Set<NSManagedObject> {
        return objects(forKey: NSInsertedObjectsKey)
    }

    public var updatedObjects: Set<NSManagedObject> {
        return objects(forKey: NSUpdatedObjectsKey)
    }

    public var deletedObjects: Set<NSManagedObject> {
        return objects(forKey: NSDeletedObjectsKey)
    }

    public var refreshedObjects: Set<NSManagedObject> {
        return objects(forKey: NSRefreshedObjectsKey)
    }

    public var invalidatedObjects: Set<NSManagedObject> {
        return objects(forKey: NSInvalidatedObjectsKey)
    }

    public var invalidatedAllObjects: Bool {
        return (self.notification as Notification).userInfo?[NSInvalidatedAllObjectsKey] != nil
    }

    public var managedObjectContext: NSManagedObjectContext {
        guard let context = self.notification.object as? NSManagedObjectContext else { fatalError("Invalid notification object") }
        return context
    }

    // MARK: Private
    private let notification: Notification

    private func objects(forKey key: String) -> Set<NSManagedObject> {
        return ((self.notification as Notification).userInfo?[key] as? Set<NSManagedObject>) ?? Set()
    }

}

extension NSManagedObjectContext {

    /// Adds the given block to the default `NotificationCenter`'s dispatch table for the given context's objects-did-change notifications.
    /// - returns: An opaque object to act as the observer. This must be sent to the default `NotificationCenter`'s `removeObserver()`.
    public func addObjectsDidChangeNotificationObserver(_ handler: @escaping (ObjectsDidChangeNotification) -> Void) -> NSObjectProtocol {
        let notificationCenter = NotificationCenter.default
        return notificationCenter.addObserver(forName: .NSManagedObjectContextObjectsDidChange, object: self, queue: nil) { note in
            let wrappedNote = ObjectsDidChangeNotification(note: note)
            handler(wrappedNote)
        }
    }

}
