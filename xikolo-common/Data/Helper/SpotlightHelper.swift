//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import Foundation
import CoreSpotlight

class SpotlightHelper {

    static func addSearchIndex(for course: Course) {
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
        let item = CSSearchableItem(uniqueIdentifier: url.absoluteString, domainIdentifier: self.getReverseDomain(appendix: "course"), attributeSet: attributeSet)
        CSSearchableIndex.default().indexSearchableItems([item]) { error in
            if let error = error {
                CrashlyticsHelper.shared.recordError(error)
                log.error(error.localizedDescription)
            } else {
                log.verbose("Item indexed.")
            }
        }
    }

    static func removeSearchIndex(for course: Course) {
        guard let url = course.url else {
            log.warning("Failed to remove search index for course (\(course.title ?? "")): no course url")
            return
        }

        CSSearchableIndex.default().deleteSearchableItems(withIdentifiers: [url.absoluteString]) { error in
            if let error = error {
                CrashlyticsHelper.shared.recordError(error)
                log.error(error.localizedDescription)
            } else {
                log.verbose("Item deleted.")
            }
        }
    }

    static func setUserActivity(for course: Course) {
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

    private static func getReverseDomain(appendix: String) -> String {
        return "\(Brand.AppID).\(appendix)"
    }

}
