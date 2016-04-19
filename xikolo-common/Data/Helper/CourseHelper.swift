//
//  CourseHelper.swift
//  xikolo-ios
//
//  Created by Jonas Müller on 30.09.15.
//  Copyright © 2015 HPI. All rights reserved.
//

import UIKit
import CoreData

class CourseHelper: NSObject {
    
    static private let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    static private let managedContext = appDelegate.managedObjectContext
    static private let entity = NSEntityDescription.entityForName("CourseCDModel", inManagedObjectContext: managedContext)
    
    static func saveCourseList(courseList: CourseList) {
    
        for index in 1...courseList.courseList.count {
            
            let course = courseList.courseList.objectAtIndex(index-1) as! Course
            
            // TODO Update stored courses
            if(!courseStored(course)) {
                let courseCoreData = CourseCDModel(entity: entity!, insertIntoManagedObjectContext: managedContext)
                
                courseCoreData.setValue(course.id, forKey: "id")
                courseCoreData.setValue(course.name, forKey: "name")
                courseCoreData.setValue(course.visual_url, forKey: "visual_url")
                courseCoreData.setValue(course.lecturer, forKey: "lecturer")
                courseCoreData.setValue(course.is_enrolled, forKey: "is_enrolled")
                courseCoreData.setValue(course.language, forKey: "language")
                courseCoreData.setValue(course.locked, forKey: "locked")
                courseCoreData.setValue(course.course_description, forKey: "course_description")
                courseCoreData.setValue(course.course_code, forKey: "course_code")
            }             
        }
        
        do {
            try managedContext.save()
            
            defer {
                print("Saving successful")
            }
            
        }
        catch _ {
            print("Error saving data to CoreData")
        }
        
    }
    
    static func getSavedCourseList() -> CourseList {
        let courseList = CourseList()
        let fetchRequest = NSFetchRequest(entityName: "CourseCDModel")
        
        do {
            let fetchedResults = try managedContext.executeFetchRequest(fetchRequest) as? [CourseCDModel]
            
            for managedObject in fetchedResults! {
                courseList.courseList.addObject(managedObject.getCourseObject())
            }
            
            defer {
                print("Loading successful")
            }
            
        }
        catch _ {
            print("Could not fetch Courses from CoreData")
        }
        
        return courseList
    }
    
    private static func courseStored(course: Course) -> Bool {
        
//        let predicateString = "course_code == " + course.course_code
        let predicate = NSPredicate(format: "id ==  %@", course.id)
        let fetchRequest = NSFetchRequest(entityName: "CourseCDModel")
        
        fetchRequest.entity = entity
        fetchRequest.predicate = predicate
        
        var count = 0
        do {
            let fetchedObjects = try managedContext.executeFetchRequest(fetchRequest)
            count = fetchedObjects.count
            
        } catch _ {
            print("Could not fetch Courses from CoreData")
        }
        
        if(count > 0) {
            return true
        }
        
        return false
    }

}
