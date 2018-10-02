//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Common
import CoreData
import CoreSpotlight
import Foundation
import UIKit

class SpotlightHelper {

    static let shared = SpotlightHelper()

    private init() {}

    func startObserving() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(coreDataChange(note:)),
                                               name: NSNotification.Name.NSManagedObjectContextObjectsDidChange,
                                               object: CoreDataHelper.viewContext)
    }

    func stopObserving() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: CoreDataHelper.viewContext)
    }

    @objc private func coreDataChange(note: Notification) {
        if let updated = note.userInfo?[NSUpdatedObjectsKey] as? Set<NSManagedObject>, !updated.isEmpty {
            for case let object as Course in updated {
                self.removeSearchIndex(for: object)
            }
        }

        if let deleted = note.userInfo?[NSDeletedObjectsKey] as? Set<NSManagedObject>, !deleted.isEmpty {
            for case let object as Course in deleted {
                self.removeSearchIndex(for: object)
            }
        }

        if let inserted = note.userInfo?[NSInsertedObjectsKey] as? Set<NSManagedObject>, !inserted.isEmpty {
            for case let object as Course in inserted {
                self.addSearchIndex(for: object)
            }
        }
    }

    private func addSearchIndex(for course: Course) {
        guard let url = course.url else {
            log.warning("Failed to add search index for course (\(course.title ?? "")): no course url")
            return
        }

        // Create an attribute set to describe an item.
        let attributeSet = CSSearchableItemAttributeSet(itemContentType: "Course")
        // Add metadata that supplies details about the item.
        attributeSet.title = course.title
        attributeSet.contentDescription = (course.abstract ?? "") + " " + (course.teachers ?? "")

        // Create an item with a unique identifier, a domain identifier, and the attribute set you created earlier.
        let item = CSSearchableItem(uniqueIdentifier: url.absoluteString,
                                    domainIdentifier: self.getReverseDomain(appendix: "course"),
                                    attributeSet: attributeSet)
        CSSearchableIndex.default().indexSearchableItems([item]) { error in
            if let error = error {
                ErrorManager.shared.report(error)
                log.error(error.localizedDescription)
            } else {
                log.verbose("Item indexed.")
            }
        }
    }

    private func removeSearchIndex(for course: Course) {
        guard let url = course.url else {
            log.warning("Failed to remove search index for course (\(course.title ?? "")): no course url")
            return
        }

        CSSearchableIndex.default().deleteSearchableItems(withIdentifiers: [url.absoluteString]) { error in
            if let error = error {
                ErrorManager.shared.report(error)
                log.error(error.localizedDescription)
            } else {
                log.verbose("Item deleted.")
            }
        }
    }

    func setUserActivity(for course: Course) {
        guard let url = course.url else {
            log.warning("Failed to set search user activity for course (\(course.title ?? "")): no course url")
            return
        }

        let activity = NSUserActivity(activityType: self.getReverseDomain(appendix: "course.view"))
        activity.title = "Viewing Course"
        activity.requiredUserInfoKeys = ["course_id"]
        activity.webpageURL = url
        activity.isEligibleForSearch = true
        activity.isEligibleForHandoff = true
        activity.isEligibleForPublicIndexing = !course.hidden
        activity.userInfo = ["course_id": course.id]
        activity.becomeCurrent()
    }

    private func getReverseDomain(appendix: String) -> String {
        return "\(UIApplication.bundleIdentifier).\(appendix)"
    }

}
