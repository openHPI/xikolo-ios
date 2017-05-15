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
import Spine

class Course : BaseModel {

    var hidden: Bool? {
        get {
            return hidden_int?.boolValue
        }
        set(new_is_hidden) {
            hidden_int = new_is_hidden as NSNumber?
        }
    }

    var accessible: Bool {
        get {
            return accessible_int?.boolValue ?? false
        }
        set(new_is_accessible) {
            accessible_int = new_is_accessible as NSNumber?
        }
    }

    var enrollable: Bool? {
        get {
            return enrollable_int?.boolValue
        }
        set(new_is_enrollable) {
            enrollable_int = new_is_enrollable as NSNumber?
        }
    }

    var external: Bool? {
        get {
            return external_int?.boolValue
        }
        set(new_is_external) {
            external_int = new_is_external as NSNumber?
        }
    }

    var is_enrolled_section: String {
        get {
            if enrollment != nil {
                return NSLocalizedString("My Courses", comment: "My Courses")
            } else {
                return NSLocalizedString("All Courses", comment: "All Courses")
            }
        }
    }

    var interesting_section = NSLocalizedString("Suggested", comment: "section title for collapsed upcoming & active courses")
    var selfpaced_section = NSLocalizedString("Self-paced", comment: "section title for selfpaced courses")
    var current_section = NSLocalizedString("Current", comment: "section title for current courses")
    var upcoming_section = NSLocalizedString("Upcoming", comment: "section title for upcoming courses")
    var completed_section = NSLocalizedString("Completed", comment: "section title for completed courses")

    var language_translated: String? {
        if let language = language {
            let locale = Locale.current
            return (locale as NSLocale).displayName(forKey: NSLocale.Key.identifier, value: language)
        }
        return nil
    }

}

extension Course : DynamicSort {

    func computeOrder() {
        self.order = NSNumber(value: abs(start_at?.timeIntervalSinceNow ?? TimeInterval.infinity))
    }

}

class CourseSpine : BaseModelSpine {

    var title: String?
    var slug: String?
    var abstract: String?
    var course_description: String?
    var certificates: CourseCertificates?
    var image_url: URL?
    var teachers: String?
    var language: String?
    var start_at: Date?
    var end_at: Date?
    var status: String?
    var hidden_int: NSNumber?
    var enrollable_int: NSNumber?
    var accessible_int: NSNumber?
    var external_int: NSNumber?

    var enrollment: EnrollmentSpine?
    var channel: ChannelSpine?

    //used for PATCH
    convenience init(course: Course){
        self.init()
        self.id = course.id
        //TODO: What about content
    }

    override class var cdType: BaseModel.Type {
        return Course.self
    }

    override class var resourceType: ResourceType {
        return "courses"
    }

    override class var fields: [Field] {
        return fieldsFromDictionary([
            "title": Attribute(),
            "slug": Attribute(),
            "abstract": Attribute(),
            "accessible_int": BooleanAttribute().serializeAs("accessible"),
            "course_description": Attribute().serializeAs("description"),
            "certificates": EmbeddedObjectAttribute(CourseCertificates.self),
            "image_url": URLAttribute(baseURL: URL(string: Brand.BaseURL)!),
            "teachers": Attribute(),
            "language": Attribute(),
            "start_at": DateAttribute(),
            "end_at": DateAttribute(),
            "status": Attribute(),
            "hidden_int": BooleanAttribute().serializeAs("hidden"),
            "enrollable_int": BooleanAttribute().serializeAs("enrollable"),
            "external_int": BooleanAttribute().serializeAs("external"),
            "enrollment": ToOneRelationship(EnrollmentSpine.self).serializeAs("user_enrollment"),
            "channel": ToOneRelationship(ChannelSpine.self),
        ])
    }

}
