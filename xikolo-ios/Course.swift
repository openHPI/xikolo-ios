//
//  Course.swift
//  xikolo-ios
//
//  Created by Arne Boockmeyer on 25/06/15.
//  Copyright © 2015 HPI. All rights reserved.
//

import Foundation
import SwiftyJSON
import Realm

class Course : RLMObject{
    
    var id : String = ""
    var name : String = ""
    var visual_url : String = ""
    var lecturer : String = ""
    var is_enrolled : Bool = false
    var language : String = ""
    var locked : Bool = false
    var course_description : String = ""
    var course_code : String = ""
    
    override init() {
        super.init()
    }
    
    // TODO: Refactor
    init(json: JSON) {
        super.init()
        
        // TODO: DRY!!!
        
        // Name
        if let courseName = json["name"].string {
            self.name = courseName
        } else {
            // Shouldn't be executed if type is right
            // TODO: Handle if this is ever called
        }
        
        // ID
        if let courseID = json["id"].string {
            self.id = courseID
        } else {
            // Shouldn't be executed if type is right
            // TODO: Handle if this is ever called
        }
        
        // Image
        if let courseImage = json["visual_url"].string {
            self.visual_url = courseImage
        } else {
            // Shouldn't be executed if type is right
            // TODO: Handle if this is ever called
        }
        
        // Lecturer
        if let lecturer = json["lecturer"].string {
            self.lecturer = lecturer
        } else {
            // Shouldn't be executed if type is right
            // TODO: Handle if this is ever called
        }
        
        // Is Enrolled
        if let enrolled = json["is_enrolled"].bool {
            self.is_enrolled = enrolled
        } else {
            // Shouldn't be executed if type is right
            // TODO: Handle if this is ever called
        }
        
        // Language
        if let language = json["language"].string {
            self.language = language
        } else {
            // Shouldn't be executed if type is right
            // TODO: Handle if this is ever called
        }
        
        // Locked
        if let locked = json["locked"].bool {
            self.locked = locked
        } else {
            // Shouldn't be executed if type is right
            // TODO: Handle if this is ever called
        }
        
        // Description
        if let description = json["description"].string {
            self.course_description = description
        } else {
            // Shouldn't be executed if type is right
            // TODO: Handle if this is ever called
        }
        
        // Code
        if let code = json["course_code"].string {
            self.course_code = code
        } else {
            // Shouldn't be executed if type is right
            // TODO: Handle if this is ever called
        }
    }
    
}