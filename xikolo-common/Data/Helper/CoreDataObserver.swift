//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import CoreData
import Foundation

class CoreDataObserver {
    static let standard = CoreDataObserver()

    func startObserving() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(coreDataChange(note:)),
                                               name: NSNotification.Name.NSManagedObjectContextObjectsDidChange,
                                               object: CoreDataHelper.viewContext)
    }

    func stopObserving() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: CoreDataHelper.viewContext)
    }

    @objc func coreDataChange(note: Notification) {
        var shouldCheckForChangesToPush = false

        if let updated = note.userInfo?[NSUpdatedObjectsKey] as? Set<NSManagedObject>, !updated.isEmpty {
            for object in updated {
                // Spotlight
                if let course = object as? Course {
                    SpotlightHelper.removeSearchIndex(for: course)
                }

                // Pushable
                if object is Pushable {
                    shouldCheckForChangesToPush = true
                }
            }
        }

        if let deleted = note.userInfo?[NSDeletedObjectsKey] as? Set<NSManagedObject>, !deleted.isEmpty {
            for object in deleted {
                // Spotlight
                if let course = object as? Course {
                    SpotlightHelper.removeSearchIndex(for: course)
                }
            }
        }

        if let inserted = note.userInfo?[NSInsertedObjectsKey] as? Set<NSManagedObject>, !inserted.isEmpty {
            for object in inserted {
                // Spotlight
                if let course = object as? Course {
                    SpotlightHelper.addSearchIndex(for: course)
                }

                // Pushable
                if object is Pushable {
                    shouldCheckForChangesToPush = true
                }
            }
        }

        if let refreshed = note.userInfo?[NSRefreshedObjectsKey] as? Set<NSManagedObject>, !refreshed.isEmpty {
            for object in refreshed {
                // Pushable
                if object is Pushable {
                    shouldCheckForChangesToPush = true
                }
            }
        }

        if shouldCheckForChangesToPush {
            SyncPushEngine.shared.check()
        }
    }
}
