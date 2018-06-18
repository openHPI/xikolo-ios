//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures
import CoreData
import Foundation

final class Course: NSManagedObject {

    @NSManaged var id: String
    @NSManaged var abstract: String?
    @NSManaged var accessible: Bool
    @NSManaged var courseDescription: String?
    @NSManaged var certificates: CourseCertificates?
    @NSManaged var startsAt: Date?
    @NSManaged var endsAt: Date?
    @NSManaged var imageURL: URL?
    @NSManaged var language: String?
    @NSManaged var slug: String?
    @NSManaged var teachers: String?
    @NSManaged var title: String?
    @NSManaged var order: NSNumber?
    @NSManaged var status: String?
    @NSManaged var hidden: Bool
    @NSManaged var enrollable: Bool
    @NSManaged var external: Bool

    @NSManaged var sections: Set<CourseSection>
    @NSManaged var enrollment: Enrollment?
    @NSManaged var dates: Set<CourseDate>

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Course> {
        return NSFetchRequest<Course>(entityName: "Course")
    }

    @objc var interestingSection = NSLocalizedString("course.section-title.suggested",
                                                     tableName: "Common",
                                                     comment: "section title for collapsed upcoming & active courses")
    @objc var selfpacedSectionName = NSLocalizedString("course.section-title.self-paced", tableName: "Common", comment: "section title for selfpaced courses")
    @objc var currentSectionName = NSLocalizedString("course.section-title.current", tableName: "Common", comment: "section title for current courses")
    @objc var upcomingSectionName = NSLocalizedString("course.section-title.upcoming", tableName: "Common", comment: "section title for upcoming courses")
    @objc var completedSectioName = NSLocalizedString("course.section-title.completed", tableName: "Common", comment: "section title for completed courses")
    @objc var isEnrolledSectionName: String {
        if enrollment != nil {
            return NSLocalizedString("course.section-title.my courses", tableName: "Common", comment: "section title for enrolled courses")
        } else {
            return NSLocalizedString("course.section-title.all courses", tableName: "Common", comment: "section title for all courses")
        }
    }

    var localizedLanguage: String? {
        guard let language = language else {
            return nil
        }

        return NSLocale(localeIdentifier: Brand.locale.identifier).displayName(forKey: NSLocale.Key.languageCode, value: language)
    }

    var url: URL? {
        guard let slug = self.slug else {
            return nil
        }

        return Routes.courses.appendingPathComponent(slug)
    }

    var hasEnrollment: Bool {
        return self.enrollment != nil && self.enrollment?.objectState != .deleted
    }

    var availableCertificates: [(name: String, explanation: String?, url: URL?)] { // swiftlint:disable:this large_tuple
        var certificates: [(String, String?, URL?)] = []

        if let certificate = self.certificates?.qualifiedCertificate, certificate.available {
            let name = NSLocalizedString("course.certificates.name.qualifiedCertificate", tableName: "Common", comment: "name of the certificate")
            let explanation = NSLocalizedString("course.certificates.explanation.qualifiedCertificate",
                                                tableName: "Common",
                                                comment: "explanation how to achieve the certificate")
            let url = self.enrollment?.certificates?.qualifiedCertificate
            certificates.append((name, explanation, url))
        }

        if let roa = self.certificates?.recordOfAchievement, roa.available {
            let name = NSLocalizedString("course.certificates.name.recordOfAchievement", tableName: "Common", comment: "name of the certificate")
            let format = NSLocalizedString("course.certificates.explanation.recordOfAchievement",
                                           tableName: "Common",
                                           comment: "explanation how to achieve the certificate")
            let explanation = roa.threshold.map { String.localizedStringWithFormat(format, Int($0)) }
            let url = self.enrollment?.certificates?.recordOfAchievement
            certificates.append((name, explanation, url))
        }

        if let cop = self.certificates?.confirmationOfParticipation, cop.available {
            let name = NSLocalizedString("course.certificates.name.confirmationOfParticipation", tableName: "Common", comment: "name of the certificate")
            let format = NSLocalizedString("course.certificates.explanation.confirmationOfParticipation",
                                           tableName: "Common",
                                           comment: "explanation how to achieve the certificate")
            let explanation = cop.threshold.map { String.localizedStringWithFormat(format, Int($0)) }
            let url = self.enrollment?.certificates?.confirmationOfParticipation
            certificates.append((name, explanation, url))
        }

        return certificates
    }

}

extension Course: Pullable {

    static var type: String {
        return "courses"
    }

    func update(withObject object: ResourceData, including includes: [ResourceData]?, inContext context: NSManagedObjectContext) throws {
        let attributes = try object.value(for: "attributes") as JSON
        self.title = try attributes.value(for: "title")
        self.slug = try attributes.value(for: "slug")
        self.abstract = try attributes.value(for: "abstract")
        self.accessible = try attributes.value(for: "accessible")
        self.courseDescription = try attributes.value(for: "description") ?? self.courseDescription
        self.certificates = try attributes.value(for: "certificates")
        self.imageURL = try attributes.value(for: "image_url")
        self.teachers = try attributes.value(for: "teachers")
        self.language = try attributes.value(for: "language")
        self.startsAt = try attributes.value(for: "start_at")
        self.endsAt = try attributes.value(for: "end_at")
        self.status = try attributes.value(for: "status")
        self.hidden = try attributes.value(for: "hidden")
        self.enrollable = try attributes.value(for: "enrollable")
        self.external = try attributes.value(for: "external")

        self.order = NSNumber(value: abs(self.startsAt?.timeIntervalSinceNow ?? TimeInterval.infinity))

        if let relationships = try? object.value(for: "relationships") as JSON {
            try self.updateRelationship(forKeyPath: \Course.enrollment,
                                        forKey: "user_enrollment",
                                        fromObject: relationships,
                                        including: includes,
                                        inContext: context)
        }

    }

}
