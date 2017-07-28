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
    static func addCourseToIndex(course:Course){
        // Create an attribute set to describe an item.
        let attributeSet = CSSearchableItemAttributeSet(itemContentType: "Course")
        // Add metadata that supplies details about the item.
        attributeSet.title = course.title
        attributeSet.contentDescription = course.abstract + " " + course.teachers
        //attributeSet.thumbnailData = DocumentImage.jpg
        let url = String.init(Brand.BaseURL + "/courses/" + course.slug!)
        // Create an item with a unique identifier, a domain identifier, and the attribute set you created earlier.
        let item = CSSearchableItem(uniqueIdentifier: url, domainIdentifier: self.getReverseDomain(appendix:"course"), attributeSet: attributeSet)
        CSSearchableIndex.default().indexSearchableItems([item]) { error in
            if error != nil {
                print(error!.localizedDescription)
            }
            else {
                print("Item indexed.")
            }
        }
    }

    static func removeCourseFromIndex(course:Course){
        let url = String.init(Brand.BaseURL + "/courses/" + course.slug!)
        CSSearchableIndex.default().deleteSearchableItems(withIdentifiers: [url!]) { error in
            if error != nil {
                print(error!.localizedDescription)
            }
            else {
                print("Item deleted.")
            }
        }
    }
    static func setNSUserActivity(course:Course){
        let activity = NSUserActivity(activityType: self.getReverseDomain(appendix: "course.view"))
        activity.title = "Viewing Course"
        activity.requiredUserInfoKeys = ["course_id"]
        activity.webpageURL = URL(string: Brand.BaseURL + "/courses/" + course.slug!)
        activity.isEligibleForSearch = true
        activity.isEligibleForHandoff = true
        if (course.hidden == false){ // internal courses?
            activity.isEligibleForPublicIndexing = true
        }
        activity.userInfo = ["course_id": course.id]
        activity.becomeCurrent()
    }

    static func getReverseDomain(appendix:String)->String{
        return Brand.AppID+"."+appendix
    }

}

