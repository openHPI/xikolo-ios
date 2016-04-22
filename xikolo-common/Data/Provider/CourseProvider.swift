//
//  CourseProvider.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 22.04.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import Alamofire
import Foundation

class CourseProvider {

    static func getCourses(completionHandler: (courses: [[String: AnyObject]]?, error: NSError?) -> ()) {
        let url = Routes.API_URL + Routes.COURSES

        Alamofire.request(.GET, url, headers: [
            Routes.HTTP_ACCEPT_HEADER: Routes.HTTP_ACCEPT_HEADER_VALUE,
            // TODO: Add auth if logged-in.
            //Routes.HTTP_AUTH_HEADER: Routes.HTTP_AUTH_HEADER_VALUE_PREFIX + UserProfileHelper.getToken(),
        ]).responseJSON() { (response: Response<AnyObject, NSError>) in
            if let courses = response.result.value as! [[String: AnyObject]]? {
                completionHandler(courses: courses, error: nil)
                return
            }
            completionHandler(courses: nil, error: response.result.error)
        }
    }

}
