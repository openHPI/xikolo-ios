//
//  CourseCDModel.swift
//  
//
//  Created by Jonas Müller on 07.10.15.
//
//

import Foundation
import CoreData

class CourseCDModel: NSManagedObject {

// Insert code here to add functionality to your managed object subclass

    internal func getCourseObject() -> Course {
    let course = Course()
    
        course.id = self.valueForKey("id") as! String
        course.name = self.valueForKey("name") as! String
        course.visual_url = self.valueForKey("visual_url") as! String
        course.lecturer = self.valueForKey("lecturer") as! String
        course.is_enrolled = self.valueForKey("is_enrolled") as! Bool
        course.language = self.valueForKey("language") as! String
        course.locked = self.valueForKey("locked") as! Bool
        course.course_description = self.valueForKey("course_description") as! String
        course.course_code = self.valueForKey("course_code") as! String
    
    return course;
    }
    
}
