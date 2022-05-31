//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import XCTest
import CoreData
import Common
@testable import iOS

@available(iOS 13, *)
class SectionsToDeleteSecondNextSectionTests: XCTestCase {

    private var context: NSManagedObjectContext!
    private var course: Course!
    private var section1: CourseSection!
    private var section2: CourseSection!
    private var section3: CourseSection!
    private var section4: CourseSection!

    override func setUpWithError() throws {
        let container = CoreDataTestHelper.newPersistentContainer()
        context = container.newBackgroundContext()

        let courseEntityDescription = NSEntityDescription.entity(forEntityName: "Course", in: context)!
        let enrollmentEntityDescription = NSEntityDescription.entity(forEntityName: "Enrollment", in: context)!
        let courseSectionEntityDescription = NSEntityDescription.entity(forEntityName: "CourseSection", in: context)!

        course = Course(entity: courseEntityDescription, insertInto: context)
        course.id = UUID().uuidString
        course.status = "active"
        course.enrollment = Enrollment(entity: enrollmentEntityDescription, insertInto: context)
        course.automatedDownloadSettings = AutomatedDownloadSettings(enableBackgroundDownloads: true)
        course.automatedDownloadSettings?.deletionOption = .secondNextSection

        section1 = CourseSection(entity: courseSectionEntityDescription, insertInto: context)
        section1.id = UUID().uuidString

        section2 = CourseSection(entity: courseSectionEntityDescription, insertInto: context)
        section2.id = UUID().uuidString

        section3 = CourseSection(entity: courseSectionEntityDescription, insertInto: context)
        section3.id = UUID().uuidString

        section4 = CourseSection(entity: courseSectionEntityDescription, insertInto: context)
        section4.id = UUID().uuidString

        course.sections = [section1, section2, section3, section4]

        section1.items = [EntityCreationHelper.newVideoItem(in: context, streamDownloaded: true)]
        section2.items = [EntityCreationHelper.newVideoItem(in: context, streamDownloaded: true)]
        section3.items = [EntityCreationHelper.newVideoItem(in: context, streamDownloaded: true)]
        section4.items = [EntityCreationHelper.newVideoItem(in: context, streamDownloaded: true)]
    }

    func testOneSection() throws {
        course.startsAt = Calendar.current.date(byAdding: .day, value: -14, to: Date())
        course.endsAt = Calendar.current.date(byAdding: .day, value: 7, to: Date())
        section1.startsAt = course.startsAt
        section1.endsAt = Calendar.current.date(byAdding: .day, value: -7, to: Date())
        section2.startsAt = section1.endsAt
        section2.endsAt = Calendar.current.date(byAdding: .day, value: -4, to: Date())
        section3.startsAt = section2.endsAt
        section3.endsAt = Calendar.current.date(byAdding: .day, value: 1, to: Date())
        section4.startsAt = section3.endsAt
        section4.endsAt = course.endsAt

        let sectionsToDelete = AutomatedDownloadsManager.sectionsToDelete(for: course)

        XCTAssertEqual(sectionsToDelete, [section1])
    }

    func testMultipleSections() throws {
        course.startsAt = Calendar.current.date(byAdding: .day, value: -14, to: Date())
        course.endsAt = Calendar.current.date(byAdding: .day, value: 7, to: Date())
        section1.startsAt = course.startsAt
        section1.endsAt = Calendar.current.date(byAdding: .day, value: -7, to: Date())
        section2.startsAt = section1.startsAt
        section2.endsAt = section1.endsAt
        section3.startsAt = section2.endsAt
        section3.endsAt = Calendar.current.date(byAdding: .day, value: -1, to: Date())
        section4.startsAt = section3.endsAt
        section4.endsAt = course.endsAt

        let sectionsToDelete = AutomatedDownloadsManager.sectionsToDelete(for: course)

        XCTAssertEqual(sectionsToDelete, [section1, section2])
    }

    func testOverlappingSections() throws {
        course.startsAt = Calendar.current.date(byAdding: .day, value: -14, to: Date())
        course.endsAt = Calendar.current.date(byAdding: .day, value: 7, to: Date())
        section1.startsAt = course.startsAt
        section1.endsAt = Calendar.current.date(byAdding: .day, value: -7, to: Date())
        section2.startsAt = course.startsAt
        section2.endsAt = course.endsAt
        section3.startsAt = Calendar.current.date(byAdding: .day, value: -4, to: Date())
        section3.endsAt = Calendar.current.date(byAdding: .day, value: -1, to: Date())
        section4.startsAt = section3.endsAt
        section4.endsAt = course.endsAt

        let sectionsToDelete = AutomatedDownloadsManager.sectionsToDelete(for: course)

        XCTAssertEqual(sectionsToDelete, [section1])
    }

    func testBeforeCourseStart() throws {
        course.startsAt = Calendar.current.date(byAdding: .day, value: 1, to: Date())
        course.endsAt = Calendar.current.date(byAdding: .day, value: 14, to: Date())
        section1.startsAt = course.startsAt
        section1.endsAt = Calendar.current.date(byAdding: .day, value: 7, to: Date())
        section2.startsAt = section1.endsAt
        section2.endsAt = Calendar.current.date(byAdding: .day, value: 10, to: Date())
        section3.startsAt = section2.endsAt
        section3.endsAt = Calendar.current.date(byAdding: .day, value: 12, to: Date())
        section4.startsAt = section3.endsAt
        section4.endsAt = course.endsAt

        let sectionsToDelete = AutomatedDownloadsManager.sectionsToDelete(for: course)

        XCTAssertEqual(sectionsToDelete, [])
    }

    func testAfterCourseEnd() throws {
        course.startsAt = Calendar.current.date(byAdding: .day, value: -14, to: Date())
        course.endsAt = Calendar.current.date(byAdding: .day, value: -1, to: Date())
        section1.startsAt = course.startsAt
        section1.endsAt = Calendar.current.date(byAdding: .day, value: -7, to: Date())
        section2.startsAt = section1.endsAt
        section2.endsAt = Calendar.current.date(byAdding: .day, value: -4, to: Date())
        section3.startsAt = section2.endsAt
        section3.endsAt = Calendar.current.date(byAdding: .day, value: -2, to: Date())
        section4.startsAt = section3.endsAt
        section4.endsAt = course.endsAt

        let sectionsToDelete = AutomatedDownloadsManager.sectionsToDelete(for: course)

        XCTAssertEqual(sectionsToDelete, [section1, section2, section3, section4])
    }

}
