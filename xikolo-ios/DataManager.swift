//
//  DataManager.swift
//  xikolo-ios
//
//  Created by Arne Boockmeyer on 25/06/15.
//  Copyright © 2015 HPI. All rights reserved.
//

import Foundation

class DataManager : NSObject {

    static func getAllCourses() -> CourseList {
        let courseListResult = CourseList()
        
        let mappingForCourse = RKObjectMapping(withClass: Course.self)
        let courseMapping = ["id":"id","name":"name","image":"image"]
        mappingForCourse.addAttributeMappingsFromDictionary(courseMapping)
        
        
        let courseResponseDescriptor = RKResponseDescriptor(mapping: mappingForCourse, method: RKRequestMethod.Any, pathPattern: nil, keyPath: "courses", statusCodes: RKStatusCodeIndexSetForClass(RKStatusCodeClass.Successful))
        
        
        let baseURL = NSURL(string:Routes.COURSES)
        let request = NSURLRequest(URL: baseURL!)
        let objectRequestOperation = RKObjectRequestOperation(request: request, responseDescriptors: [courseResponseDescriptor])
        objectRequestOperation.setCompletionBlockWithSuccess({ (operation,result) -> Void in
            courseListResult.courseList = result.array()
            }) { (operation, error) -> Void in
            }
        
        objectRequestOperation.start()
        
        return courseListResult
    }
    
}