//
//  CoreDataObserver.swift
//  xikolo-ios
//
//  Created by Jan Renz and Max Bothe
//  Copyright © 2017 HPI. All rights reserved.
//

import Foundation
import CoreData


class CoreDataObserver {
    static let standard = CoreDataObserver()

    func startObserving() {
        NotificationCenter.default.addObserver(self, selector: #selector(coreDataChange(note:)), name: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: CoreDataHelper.viewContext)
    }

    func stopObserving() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: CoreDataHelper.viewContext)
    }

    //support for videos should follow once they contain the seo texts
    
    @objc func coreDataChange(note: Notification) {
        var shouldCheckForChangesToPush = false

        if let updated = note.userInfo?[NSUpdatedObjectsKey] as? Set<NSManagedObject>, updated.count > 0 {
            for object in updated {
                // Spotlight
                if let course = object as? Course {
                    SpotlightHelper.removeSearchIndex(for: course)
                }

                // Pushable
                if let pushableResource = object as? Pushable {
                    shouldCheckForChangesToPush = true
                }
            }
        }

        if let deleted = note.userInfo?[NSDeletedObjectsKey] as? Set<NSManagedObject>, deleted.count > 0 {
            for object in deleted {
                // Spotlight
                if let course = object as? Course {
                    SpotlightHelper.removeSearchIndex(for: course)
                }

                // PendingRelationship
                if let pullableResource = object as? (NSManagedObject & Pullable) {
                    PendingRelationshipHelper.deletePendingRelationship(forOrigin: pullableResource)
                }
            }
        }

        if let inserted = note.userInfo?[NSInsertedObjectsKey] as? Set<NSManagedObject>, inserted.count > 0 {
            for object in inserted {
                // Spotlight
                if let course = object as? Course {
                    SpotlightHelper.addSearchIndex(for: course)
                }

                // PendingRelationship
                if let pullableResource = object as? (NSManagedObject & Pullable) {
                    PendingRelationshipHelper.conntectResources(withObject: pullableResource)
                } else if let pendingRelationship = object as? PendingRelationship {
                    PendingRelationshipHelper.conntectResources(withRelationship: pendingRelationship)
                }

                // Pushable
                if let pushableResource = object as? Pushable {
                    shouldCheckForChangesToPush = true
                }
            }
        }

        if shouldCheckForChangesToPush {
            SyncPushEngine.shared.check()
        }
    }
}
