//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures
import CoreData
import Foundation
import Stockpile

public final class Course: NSManagedObject {

    @NSManaged public var id: String
    @NSManaged public var abstract: String?
    @NSManaged public var accessible: Bool
    @NSManaged public var courseDescription: String?
    @NSManaged public var certificates: CourseCertificates?
    @NSManaged public var startsAt: Date?
    @NSManaged public var endsAt: Date?
    @NSManaged public var imageURL: URL?
    @NSManaged public var language: String?
    @NSManaged public var slug: String?
    @NSManaged public var teachers: String?
    @NSManaged public var title: String?
    @NSManaged public var order: NSNumber?
    @NSManaged public var status: String?
    @NSManaged public var hidden: Bool
    @NSManaged public var enrollable: Bool
    @NSManaged public var external: Bool
    @NSManaged public var lastVisited: Date?
    @NSManaged public var teaserStream: VideoStream?
    @NSManaged public var categories: String?
    @NSManaged public var topics: String?

    @NSManaged public var channel: Channel?
    @NSManaged public var sections: Set<CourseSection>
    @NSManaged public var enrollment: Enrollment?
    @NSManaged public var dates: Set<CourseDate>
    @NSManaged public var documents: Set<Document>

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Course> {
        return NSFetchRequest<Course>(entityName: "Course")
    }

    @objc var interestingSection = CommonLocalizedString("course.section-title.suggested", comment: "section title for collapsed upcoming & active courses")
    @objc var selfpacedSectionName = CommonLocalizedString("course.section-title.self-paced", comment: "section title for selfpaced courses")
    @objc var currentSectionName = CommonLocalizedString("course.section-title.current", comment: "section title for current courses")
    @objc var upcomingSectionName = CommonLocalizedString("course.section-title.upcoming", comment: "section title for upcoming courses")
    @objc var completedSectioName = CommonLocalizedString("course.section-title.completed", comment: "section title for completed courses")
    @objc var isEnrolledSectionName: String {
        if enrollment != nil {
            return CommonLocalizedString("course.section-title.my courses", comment: "section title for enrolled courses")
        } else {
            return CommonLocalizedString("course.section-title.all courses", comment: "section title for all courses")
        }
    }

    public static func localize(language: String) -> String? {
        let localeIdentifier = language == "cn" ? "zh-cn" : language
        let locale = NSLocale(localeIdentifier: localeIdentifier)
        let displayName = locale.displayName(forKey: NSLocale.Key.languageCode, value: localeIdentifier)
        return displayName?.capitalized
    }

    public var localizedLanguage: String? {
        return self.language.flatMap(Self.localize)
    }

    public var url: URL? {
        guard let slug = self.slug else {
            return nil
        }

        return Routes.courses.appendingPathComponent(slug)
    }

    public var hasEnrollment: Bool {
        return self.enrollment != nil && self.enrollment?.objectState != .deleted
    }

    public var openCourseUserActivity: NSUserActivity {
        let userActivity = NSUserActivity(activityType: "com.xikolo.openCourse")
        userActivity.title = "openCourse"
        userActivity.userInfo = ["courseId": id ]
        return userActivity
    }

}

extension Course: JSONAPIPullable {

    public static var type: String {
        return "courses"
    }

    public func update(from object: ResourceData, with context: SynchronizationContext) throws {
        let attributes = try object.value(for: "attributes") as JSON
        self.title = try attributes.value(for: "title")
        self.slug = try attributes.value(for: "slug")
        self.abstract = try attributes.value(for: "abstract")
        self.accessible = try attributes.value(for: "accessible")
        self.courseDescription = try attributes.value(for: "description") ?? self.courseDescription
        self.certificates = try attributes.value(for: "certificates")
        self.imageURL = try attributes.failsafeURL(for: "image_url")
        self.teachers = try attributes.value(for: "teachers")
        self.language = try attributes.value(for: "language")
        self.startsAt = try attributes.value(for: "start_at")
        self.endsAt = try attributes.value(for: "end_at")
        self.status = try attributes.value(for: "status")
        self.hidden = try attributes.value(for: "hidden")
        self.enrollable = try attributes.value(for: "enrollable")
        self.external = try attributes.value(for: "external")
        self.teaserStream = try attributes.value(for: "teaser_stream") ?? self.teaserStream

        let categoryValues = try attributes.value(for: "classifiers.category") as [String]?
        self.categories = Self.arrayString(for: categoryValues)

        let topicValues = try attributes.value(for: "classifiers.topic") as [String]?
        self.topics = Self.arrayString(for: topicValues)

        self.order = NSNumber(value: abs(self.startsAt?.timeIntervalSinceNow ?? TimeInterval.infinity))

        if let relationships = try? object.value(for: "relationships") as JSON {
            try self.updateRelationship(forKeyPath: \Self.enrollment,
                                        forKey: "user_enrollment",
                                        fromObject: relationships,
                                        with: context)
        }
    }

    private static func arrayString(for values: [String]?) -> String? {
        return values?.joined(separator: ";")
    }

    public static func arrayValues(for arrayString: String?) -> [String]? {
        return arrayString?.split(separator: ";").compactMap(String.init)
    }

}

extension Course {

    public typealias Certificate = (name: String, explanation: String?, url: URL?)

    public var availableCertificates: [Certificate] {
        var certificates: [Certificate] = []

        if let certificate = self.certificates?.qualifiedCertificate, certificate.available {
            let name = CommonLocalizedString("course.certificates.name.qualifiedCertificate", comment: "name of the certificate")
            let explanation = CommonLocalizedString("course.certificates.explanation.qualifiedCertificate",
                                                    comment: "explanation how to achieve the certificate")
            let url = self.enrollment?.certificates?.qualifiedCertificate
            certificates.append((name, explanation, url))
        }

        if let roa = self.certificates?.recordOfAchievement, roa.available {
            let name = CommonLocalizedString("course.certificates.name.recordOfAchievement", comment: "name of the certificate")
            let format = CommonLocalizedString("course.certificates.explanation.recordOfAchievement", comment: "explanation how to achieve the certificate")
            let explanation = roa.threshold.map { String.localizedStringWithFormat(format, Int($0)) }
            let url = self.enrollment?.certificates?.recordOfAchievement
            certificates.append((name, explanation, url))
        }

        if let cop = self.certificates?.confirmationOfParticipation, cop.available {
            let name = CommonLocalizedString("course.certificates.name.confirmationOfParticipation", comment: "name of the certificate")
            let format = CommonLocalizedString("course.certificates.explanation.confirmationOfParticipation",
                                               comment: "explanation how to achieve the certificate")
            let explanation = cop.threshold.map { String.localizedStringWithFormat(format, Int($0)) }
            let url = self.enrollment?.certificates?.confirmationOfParticipation
            certificates.append((name, explanation, url))
        }

        return certificates
    }

}
