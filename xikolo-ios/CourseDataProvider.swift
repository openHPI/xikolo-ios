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
        
        let urlString = "https://staging.openhpi.de/api/courses/"
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        var courseList = CourseList()
        
        request.addValue(Routes.HTTP_ACCEPT_HEADER_VALUE, forHTTPHeaderField: Routes.HTTP_ACCEPT_HEADER)
        request.addValue("Token token=\"02408a79aa5aaf93fcd473f0edeb95de25cada520dd512d03f0bde07aad8e71c\"", forHTTPHeaderField: Routes.HTTP_AUTH_HEADER)
        
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
            
            return courseList
            
        }
    }
}
