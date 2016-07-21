//
//  Course.swift
//  xikolo-ios
//
//  Created by Sebastian Brückner on 22.04.16.
//  Copyright © 2016 HPI. All rights reserved.
//

import BrightFutures
import CoreData
import Foundation
import Result

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
            if is_enrolled {
                return NSLocalizedString("My Courses", comment: "My Courses")
            } else {
                return NSLocalizedString("All Courses", comment: "All Courses")
            }
        }
    }

    var language_translated: String? {
        if let language = language {
            let locale = NSLocale.currentLocale()
            return locale.displayNameForKey(NSLocaleIdentifier, value: language)
        }
        return nil
    }

    func loadImage() -> Future<UIImage, XikoloError> {
        if let image = image {
            return future {
                Result.Success(image)
            }
        }
        if image_url == nil {
            return future {
                return Result.Failure(XikoloError.ModelIncomplete)
            }
        }
        return ImageProvider.loadImage(image_url!).onSuccess { image in
            self.image = image
            CoreDataHelper.saveContext()
        }
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
