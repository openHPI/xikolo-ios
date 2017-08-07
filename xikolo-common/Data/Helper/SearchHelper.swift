//
//  SearchHelper.swift
//  xikolo-ios
//
//  Created by Jan Renz on 26/07/2017.
//  Copyright © 2017 HPI. All rights reserved.
//

import Foundation
import CoreSpotlight

class SearchHelper{

    static func addSearchIndex(for course: Course) {
        guard let url = course.url else {
            print("Failed to add search index for course (\(course.title ?? "")): no course url")
            return
        }

        // Create an attribute set to describe an item.
        let attributeSet = CSSearchableItemAttributeSet(itemContentType: "Course")
        // Add metadata that supplies details about the item.
        attributeSet.title = course.title
        attributeSet.contentDescription = (course.abstract ?? "") + " " + (course.teachers ?? "")
        //attributeSet.thumbnailData = DocumentImage.jpg

        // Create an item with a unique identifier, a domain identifier, and the attribute set you created earlier.
        let item = CSSearchableItem(uniqueIdentifier: url.absoluteString, domainIdentifier: self.getReverseDomain(appendix:"course"), attributeSet: attributeSet)
        CSSearchableIndex.default().indexSearchableItems([item]) { error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("Item indexed.")
            }
        }
    }

    static func removeSearchIndex(for course: Course) {
        guard let url = course.url else {
            print("Failed to remove search index for course (\(course.title ?? "")): no course url")
            return
        }

        CSSearchableIndex.default().deleteSearchableItems(withIdentifiers: [url.absoluteString]) { error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("Item deleted.")
            }
        }
    }

    static func setUserActivity(for course: Course) {
        guard let url = course.url else {
            print("Failed to set search user activity for course (\(course.title ?? "")): no course url")
            return
        }

        let activity = NSUserActivity(activityType: self.getReverseDomain(appendix: "course.view"))
        activity.title = "Viewing Course"
        activity.requiredUserInfoKeys = ["course_id"]
        activity.webpageURL = url
        activity.isEligibleForSearch = true
        activity.isEligibleForHandoff = true
        activity.isEligibleForPublicIndexing = !(course.hidden ?? true)
        activity.userInfo = ["course_id": course.id]
        activity.becomeCurrent()
    }

    private static func getReverseDomain(appendix: String) -> String {
        return "\(Brand.AppID).\(appendix)"
    }

}
