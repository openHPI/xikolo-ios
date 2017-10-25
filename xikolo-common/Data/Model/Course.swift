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
import Marshal

@objcMembers
final class Course : BaseModel {

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
                return NSLocalizedString("course.section-title.my courses", tableName: "Common", comment: "section title for enrolled courses")
            } else {
                return NSLocalizedString("course.section-title.all courses", tableName: "Common", comment: "section title for all courses")
            }
        }
    }

    var interesting_section = NSLocalizedString("course.section-title.suggested", tableName: "Common", comment: "section title for collapsed upcoming & active courses")
    var selfpaced_section = NSLocalizedString("course.section-title.self-paced", tableName: "Common", comment: "section title for selfpaced courses")
    var current_section = NSLocalizedString("course.section-title.current", tableName: "Common", comment: "section title for current courses")
    var upcoming_section = NSLocalizedString("course.section-title.upcoming", tableName: "Common", comment: "section title for upcoming courses")
    var completed_section = NSLocalizedString("course.section-title.completed", tableName: "Common", comment: "section title for completed courses")

    var language_translated: String? {
        if let language = language {
            let locale = Locale.current
            return (locale as NSLocale).displayName(forKey: NSLocale.Key.identifier, value: language)
        }
        return nil
    }

    var url: URL? {
        if let slug = self.slug {
            return URL(string: "\(Brand.BaseURL)/courses/\(slug)")
        }
        return nil
    }

}

extension Course : DynamicSort {

    func computeOrder() {
        self.order = NSNumber(value: abs(start_at?.timeIntervalSinceNow ?? TimeInterval.infinity))
    }

}

extension Course: Pullable {

    func populate(fromObject object: MarshaledObject, including includes: [MarshaledObject]?, inContext context: NSManagedObjectContext) throws {
        let attributes = try object.value(for: "attributes") as JSONObject
        self.title = try attributes.value(for: "title")
        self.slug = try attributes.value(for: "slug")
        self.abstract = try attributes.value(for: "abstract")
        self.accessible = try attributes.value(for: "accessible")
        self.course_description = try attributes.value(for: "description")
        self.certificates = try attributes.value(for: "certificates")
        self.image_url = try attributes.value(for: "image_url")
        self.teachers = try attributes.value(for: "teachers")
        self.language = try attributes.value(for: "language")
        self.start_at = try attributes.value(for: "start_at")
        self.end_at = try attributes.value(for: "end_at")
        self.status = try attributes.value(for: "status")
        self.hidden = try attributes.value(for: "hidden")
        self.enrollable = try attributes.value(for: "enrollable")
        self.external = try attributes.value(for: "external")

        let relationships = try object.value(for: "relationships") as JSONObject
        try self.updateRelationship(forKeyPath: \Course.enrollment, forKey: "user_enrollment", fromObject: relationships, including: includes, inContext: context)
//        self.enrollment = try relationships.value(forRelationship: "user_enrollment.data", including: includes, inContext: context)
//        self.identifier.enrollment = try relationships.value(forRelationship: "user_enrollment", including: includes, inContext: context)
//        or: self.identifier.enrollment = try relationships.value(forRelationship: "user_enrollment", existingObject: self.identifier.enrollemtn, including: includes, inContext: context)
//        - key includes context currentObject
//        self.updateRelationship(withKeyPath: \Course.identifier.enrollment, fromObject: relationships, forKey: "user_enrollment", including: includes, inContext: context)
//        - object keyPath key includes context
    }

}



@objcMembers
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
