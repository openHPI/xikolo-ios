//
//  CourseList.swift
//  xikolo-ios
//
//  Created by Arne Boockmeyer on 25/06/15.
//  Copyright © 2015 HPI. All rights reserved.
//

import Foundation
import SwiftyJSON

class CourseList : NSObject {

    var courseList : NSMutableArray = []
    
    override init() {
        super.init()
    }
    
    init(json: JSON) {
        
        for courseJson in json.array! {
            
            courseList.addObject(Course(json: courseJson))
            
        }
        
    }

}