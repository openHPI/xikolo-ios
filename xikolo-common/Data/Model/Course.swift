//
//  Course.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 22.04.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import CoreData
import Foundation

class Course : BaseModel {

    var is_enrolled: Bool {
        get {
            return is_enrolled_int?.boolValue ?? false
        }
        set(new_is_enrolled) {
            is_enrolled_int = new_is_enrolled
        }
    }

    var is_enrolled_section: String {
        get {
            return is_enrolled ? "My Courses" : "All Courses"
        }
    }

    var language_translated: String? {
        if let language = language {
            let locale = NSLocale.currentLocale()
            return locale.displayNameForKey(NSLocaleIdentifier, value: language)
        }
        return nil
    }

    func loadFromDict(dict: [String: AnyObject]) {
        course_code = dict["course_code"] as? String
        course_description = dict["description"] as? String
        name = dict["name"] as? String
        teachers = dict["lecturer"] as? String
        language = dict["language"] as? String
        image_url = dict["visual_url"] as? String
        start_date = NSDate.dateFromISOString(dict["available_from"] as? String)
        end_date = NSDate.dateFromISOString(dict["available_to"] as? String)
        is_enrolled = (dict["is_enrolled"] as? Bool) ?? false
    }

}
