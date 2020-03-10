//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import CoreData
import SyncEngine

public final class CourseDate: NSManagedObject {

    @available(iOS 13, *)
    private static let relativeCourseDateTimeFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.calendar = Calendar.autoupdatingCurrent
        formatter.locale = Locale.autoupdatingCurrent
        formatter.dateTimeStyle = .named
        formatter.formattingContext = .beginningOfSentence
        return formatter
    }()

    @NSManaged public var id: String
    @NSManaged public var title: String?
    @NSManaged public var type: String?
    @NSManaged public var date: Date?
    @NSManaged public var course: Course?

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CourseDate> {
        return NSFetchRequest<CourseDate>(entityName: "CourseDate")
    }

    @available(iOS 13, *)
    @objc public var relativeDateTime: String? {
        guard let date = self.date else { return nil }

        // `RelativeDateTimeFormatter` returns incorrect results for named time intervals. For example:
        // - time intervals of 40 hours whch pass the date line twice return 'tomorrow' instead of 'in 2 days'
        // Therefore, we adjust the reference date used to determine the localized string.
        let dateIsMoreThan24HoursInFuture = date.timeIntervalSinceNow > 24 * 60 * 60
        let referenceDate = dateIsMoreThan24HoursInFuture ? Self.relativeCourseDateTimeFormatter.calendar.startOfDay(for: Date()) : Date()
        return Self.relativeCourseDateTimeFormatter.localizedString(for: date, relativeTo: referenceDate)
    }

    public var contextAwareTitle: String {
        let title = self.title ?? "Unknown"
        switch self.type {
        case "course_start"?:
            return CommonLocalizedString("course-date-cell.course-start.title",
                                         comment: "title for course start in a course date cell")
        case "section_start"?:
            let format = CommonLocalizedString("course-date-cell.section-start.title.%@ starts",
                                               comment: "format for section start in course date cell")
            return String.localizedStringWithFormat(format, title)
        case "item_submission_deadline"?:
            let format = CommonLocalizedString("course-date-cell.item-submission.title.submission for %@ ends",
                                               comment: "format for item submission in course date cell")
            return String.localizedStringWithFormat(format, title)
        default:
            return title
        }
    }

}

extension CourseDate: JSONAPIPullable {

    public static var type: String {
        return "course-dates"
    }

    public func update(from object: ResourceData, with context: SynchronizationContext) throws {
        let attributes = try object.value(for: "attributes") as JSON
        self.title = try attributes.value(for: "title")
        self.type = try attributes.value(for: "type")
        self.date = try attributes.value(for: "date")

        let relationships = try object.value(for: "relationships") as JSON
        try self.updateRelationship(forKeyPath: \Self.course, forKey: "course", fromObject: relationships, with: context)
    }

}
