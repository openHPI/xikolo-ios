//
//  SyncHelper.swift
//  xikolo-ios
//
//  Created by Jan Renz and Max Bothe
//  Copyright © 2017 HPI. All rights reserved.
//

import Foundation
import CoreData


class SyncHelper {
    static let standard = SyncHelper()

    func startObserving() {
        NotificationCenter.default.addObserver(self, selector: #selector(coreDataChange(note:)), name: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: CoreDataHelper.viewContext)
         NotificationCenter.default.addObserver(self, selector: #selector(coreDataChange(note:)), name: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: CoreDataHelper.backgroundContext)
    }

    func stopObserving() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: CoreDataHelper.viewContext)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextDidSave, object: CoreDataHelper.backgroundContext)
    }

    //support for videos should follow once they contain the seo texts
    
    @objc func coreDataChange(note: Notification) {
        if let updated = note.userInfo?[NSUpdatedObjectsKey] as? Set<NSManagedObject>, updated.count > 0 {
            for case let course as Course in updated {
                SearchHelper.addCourseToIndex(course: course)
            }
        }

        if let deleted = note.userInfo?[NSDeletedObjectsKey] as? Set<NSManagedObject>, deleted.count > 0 {
            for case let course as Course in deleted {
                SearchHelper.removeCourseFromIndex(course: course)
            }
        }

        if let inserted = note.userInfo?[NSInsertedObjectsKey] as? Set<NSManagedObject>, inserted.count > 0 {

            for case let course as Course in inserted {
                SearchHelper.addCourseToIndex(course: course)
            }
        }
    }
}
