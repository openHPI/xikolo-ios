//
//  CourseItemProvider.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 13.05.16.
//  Copyright © 2016 HPI. All rights reserved.
//

//import BrightFutures
//import Foundation
//import Spine
//
//class CourseItemProvider {
//
//    class func getCourseItems(_ sectionId: String) -> Future<[CourseItemSpine], XikoloError> {
//        var query = Query(resourceType: CourseItemSpine.self)
//        query.addPredicateWithKey("section", value: sectionId, type: .equalTo)
//
//        return SpineHelper.find(query)
//    }
//
//    class func getVideosFor(course: Course) -> Future<[CourseItemSpine], XikoloError> {
//        var query = Query(resourceType: CourseItemSpine.self)
//        query.addPredicateWithKey("course", value: course.id, type: .equalTo)
//        query.addPredicateWithKey("content_type", value: "video", type: .equalTo)
//        query.include("content")
//        return SpineHelper.find(query)
//    }
//
//    class func getRichTextsFor(course: Course) -> Future<[CourseItemSpine], XikoloError> {
//        var query = Query(resourceType: CourseItemSpine.self)
//        query.addPredicateWithKey("course", value: course.id, type: .equalTo)
//        query.addPredicateWithKey("content_type", value: "rich_text", type: .equalTo)
//        query.include("content")
//        return SpineHelper.find(query)
//    }
//
//}

