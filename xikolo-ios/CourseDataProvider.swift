//
//  CourseDataProvider.swift
//  xikolo-ios
//
//  Created by Jonas Müller on 24.08.15.
//  Copyright © 2015 HPI. All rights reserved.
//

import UIKit
import SwiftyJSON

#if !RX_NO_MODULE
    import RxSwift
    import RxCocoa
#endif

class CourseDataProvider: NSObject {
    
    static let urlSession = NSURLSession.sharedSession()
    
    static func getCourseList() -> Observable<CourseList> {
        
        let local = just(CourseHelper.getSavedCourseList())
        let network = getNetworkCourseList()
        
        return concat([local,network])
    }
    
    private static func getNetworkCourseList() -> Observable<CourseList> {
        
        let urlString = Routes.API_URL + Routes.COURSES
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        var courseList = CourseList()
        
        request.addValue(Routes.HTTP_ACCEPT_HEADER_VALUE, forHTTPHeaderField: Routes.HTTP_ACCEPT_HEADER)
        request.addValue("Token token=\"" + UserProfileHelper.getToken() + "\"", forHTTPHeaderField: Routes.HTTP_AUTH_HEADER)
        
        print("Starting network request")
        
        return self.urlSession.rx_response(request).map{(maybeData, maybeResponse) in
            
            if let response = maybeResponse as? NSHTTPURLResponse {
                // TODO:
                // Check Response Status (shoulde be 200?)
                // Parse JSON Data
                // Fill Course List
                
                let json = JSON(data: maybeData)
                courseList = CourseList(json: json)
                
            }
            
            print("Network request finished")
            
            // Saving courses to CoreData
            CourseHelper.saveCourseList(courseList)
            
            return courseList
            
        }
    }
    
    static func getMyCourses() -> Observable<CourseList> {
        return self.getCourseList().map{courseList in
            let removeArray = courseList.courseList.filteredArrayUsingPredicate(NSPredicate(format: "is_enrolled == false", argumentArray: nil))
            courseList.courseList.removeObjectsInArray(removeArray)
            return courseList
        }
    }
}
