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
        // TODO:
        // Start network request
        // Deliver stored data
        // Deliver network data
        
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
            
            // DEBUG LOGGING
            var counter = -1;
            let cl = CourseHelper.getSavedCourseList()
            for c in cl.courseList {
                let managedCourse = c as! NSManagedObject
                let course = Course()
                
                course.id = managedCourse.valueForKey("id") as! String
                course.name = managedCourse.valueForKey("name") as! String
                course.visual_url = managedCourse.valueForKey("visual_url") as! String
                course.lecturer = managedCourse.valueForKey("lecturer") as! String
                course.is_enrolled = managedCourse.valueForKey("is_enrolled") as! Bool
                course.language = managedCourse.valueForKey("language") as! String
                course.locked = managedCourse.valueForKey("locked") as! Bool
                course.course_description = managedCourse.valueForKey("course_description") as! String
                course.course_code = managedCourse.valueForKey("course_code") as! String
                
                if(course.name.compare("Test & Test") == NSComparisonResult.OrderedSame) {
                    counter++
                }
            }
            //END DEBUG LOGGING
            
            print("Duplications: \(counter)")
            
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
