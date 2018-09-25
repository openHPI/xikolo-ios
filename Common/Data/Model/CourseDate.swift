//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import CoreData
import SyncEngine

public final class CourseDate: NSManagedObject {

    @NSManaged public var id: String
    @NSManaged public var title: String?
    @NSManaged public var type: String?
    @NSManaged public var date: Date?
    @NSManaged public var course: Course?

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CourseDate> {
        return NSFetchRequest<CourseDate>(entityName: "CourseDate")
    }

    private static let defaultDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter.localizedFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        return dateFormatter
    }()

    public var defaultDateString: String? {
        guard let date = self.date else {
            return nil
        }

        var dateText = CourseDate.defaultDateFormatter.string(from: date)
        if let timeZoneAbbreviation = TimeZone.current.abbreviation() {
            dateText += " (\(timeZoneAbbreviation))"
        }

        return dateText
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

extension CourseDate: Pullable {

    public static var type: String {
        return "course-dates"
    }

    public func update(from object: ResourceData, with context: SynchronizationContext) throws {
        let attributes = try object.value(for: "attributes") as JSON
        self.title = try attributes.value(for: "title")
        self.type = try attributes.value(for: "type")
        self.date = try attributes.value(for: "date")

        let relationships = try object.value(for: "relationships") as JSON
        try self.updateRelationship(forKeyPath: \CourseDate.course, forKey: "course", fromObject: relationships, with: context)
    }

}
