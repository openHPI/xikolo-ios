//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import Common
import CoreData
@testable import iOS
import XCTest

@available(iOS 13, *)
class SectionsToDownloadTests: XCTestCase {

    private var context: NSManagedObjectContext!
    private var course: Course!
    private var section1: CourseSection!
    private var section2: CourseSection!

    override func setUpWithError() throws {
        try super.setUpWithError()

        let container = CoreDataTestHelper.newPersistentContainer()
        context = container.newBackgroundContext()

        let courseEntityDescription = NSEntityDescription.entity(forEntityName: "Course", in: context)!
        let enrollmentEntityDescription = NSEntityDescription.entity(forEntityName: "Enrollment", in: context)!
        let courseSectionEntityDescription = NSEntityDescription.entity(forEntityName: "CourseSection", in: context)!

        course = Course(entity: courseEntityDescription, insertInto: context)
        course.id = UUID().uuidString
        course.startsAt = Calendar.current.date(byAdding: .day, value: 7, to: Date())
        course.endsAt = Calendar.current.date(byAdding: .day, value: 21, to: Date())
        course.status = "active"
        course.enrollment = Enrollment(entity: enrollmentEntityDescription, insertInto: context)
        course.automatedDownloadSettings = AutomatedDownloadSettings(enableBackgroundDownloads: true)

        section1 = CourseSection(entity: courseSectionEntityDescription, insertInto: context)
        section1.id = UUID().uuidString
        section1.startsAt = Calendar.current.date(byAdding: .day, value: 7, to: Date())
        section1.endsAt = Calendar.current.date(byAdding: .day, value: 14, to: Date())

        section2 = CourseSection(entity: courseSectionEntityDescription, insertInto: context)
        section2.id = UUID().uuidString
        section2.startsAt = Calendar.current.date(byAdding: .day, value: 14, to: Date())
        section2.endsAt = Calendar.current.date(byAdding: .day, value: 21, to: Date())

        course.sections = [section1, section2]
    }

    func testOneSection() throws {
        section1.items = [try EntityCreationHelper.newVideoItem(in: context)]

        course.startsAt = Calendar.current.date(byAdding: .day, value: -1, to: Date())
        course.endsAt = Calendar.current.date(byAdding: .day, value: 14, to: Date())
        section1.startsAt = course.startsAt
        section1.endsAt = Calendar.current.date(byAdding: .day, value: 7, to: Date())
        section2.startsAt = section1.endsAt
        section2.endsAt = course.endsAt

        let sectionsToDownloads = AutomatedDownloadsManager.sectionsToDownload(for: course)

        XCTAssertEqual(sectionsToDownloads, [section1])
    }

    func testOneSectionNoItem() throws {
        course.startsAt = Calendar.current.date(byAdding: .day, value: -1, to: Date())
        course.endsAt = Calendar.current.date(byAdding: .day, value: 14, to: Date())
        section1.startsAt = course.startsAt
        section1.endsAt = Calendar.current.date(byAdding: .day, value: 7, to: Date())
        section2.startsAt = section1.endsAt
        section2.endsAt = course.endsAt

        let sectionsToDownloads = AutomatedDownloadsManager.sectionsToDownload(for: course)

        XCTAssertEqual(sectionsToDownloads, [])
    }

    func testMultipleSections() throws {
        section1.items = [try EntityCreationHelper.newVideoItem(in: context)]
        section2.items = [try EntityCreationHelper.newVideoItem(in: context)]

        course.startsAt = Calendar.current.date(byAdding: .day, value: -1, to: Date())
        course.endsAt = Calendar.current.date(byAdding: .day, value: 14, to: Date())
        section1.startsAt = course.startsAt
        section1.endsAt = course.endsAt
        section2.startsAt = course.startsAt
        section2.endsAt = course.endsAt

        let sectionsToDownloads = AutomatedDownloadsManager.sectionsToDownload(for: course)

        XCTAssertEqual(sectionsToDownloads, [section1, section2])
    }

    func testMultipleSectionsNoItem() throws {
        course.startsAt = Calendar.current.date(byAdding: .day, value: -1, to: Date())
        course.endsAt = Calendar.current.date(byAdding: .day, value: 14, to: Date())
        section1.startsAt = course.startsAt
        section1.endsAt = course.endsAt
        section2.startsAt = course.startsAt
        section2.endsAt = course.endsAt

        let sectionsToDownloads = AutomatedDownloadsManager.sectionsToDownload(for: course)

        XCTAssertEqual(sectionsToDownloads, [])
    }

    func testMultipleSectionsNoItemSection1() throws {
        section2.items = [try EntityCreationHelper.newVideoItem(in: context)]

        course.startsAt = Calendar.current.date(byAdding: .day, value: -1, to: Date())
        course.endsAt = Calendar.current.date(byAdding: .day, value: 14, to: Date())
        section1.startsAt = course.startsAt
        section1.endsAt = course.endsAt
        section2.startsAt = course.startsAt
        section2.endsAt = course.endsAt

        let sectionsToDownloads = AutomatedDownloadsManager.sectionsToDownload(for: course)

        XCTAssertEqual(sectionsToDownloads, [section2])
    }

    func testMultipleSectionsNoItemSection2() throws {
        section1.items = [try EntityCreationHelper.newVideoItem(in: context)]

        course.startsAt = Calendar.current.date(byAdding: .day, value: -1, to: Date())
        course.endsAt = Calendar.current.date(byAdding: .day, value: 14, to: Date())
        section1.startsAt = course.startsAt
        section1.endsAt = course.endsAt
        section2.startsAt = course.startsAt
        section2.endsAt = course.endsAt

        let sectionsToDownloads = AutomatedDownloadsManager.sectionsToDownload(for: course)

        XCTAssertEqual(sectionsToDownloads, [section1])
    }

    func testOverlappingSections() throws {
        section1.items = [try EntityCreationHelper.newVideoItem(in: context)]
        section2.items = [try EntityCreationHelper.newVideoItem(in: context)]

        course.startsAt = Calendar.current.date(byAdding: .day, value: -14, to: Date())
        course.endsAt = Calendar.current.date(byAdding: .day, value: 1, to: Date())
        section1.startsAt = course.startsAt
        section1.endsAt = Calendar.current.date(byAdding: .day, value: -7, to: Date())
        section2.startsAt = course.startsAt
        section2.endsAt = course.endsAt

        let sectionsToDownloads = AutomatedDownloadsManager.sectionsToDownload(for: course)

        XCTAssertEqual(sectionsToDownloads, [section2])
    }

    func testOverlappingSectionsNoItem() throws {
        course.startsAt = Calendar.current.date(byAdding: .day, value: -14, to: Date())
        course.endsAt = Calendar.current.date(byAdding: .day, value: 1, to: Date())
        section1.startsAt = course.startsAt
        section1.endsAt = Calendar.current.date(byAdding: .day, value: -7, to: Date())
        section2.startsAt = course.startsAt
        section2.endsAt = course.endsAt

        let sectionsToDownloads = AutomatedDownloadsManager.sectionsToDownload(for: course)

        XCTAssertEqual(sectionsToDownloads, [])
    }

    func testOverlappingSectionsNoItemSection1() throws {
        section2.items = [try EntityCreationHelper.newVideoItem(in: context)]

        course.startsAt = Calendar.current.date(byAdding: .day, value: -14, to: Date())
        course.endsAt = Calendar.current.date(byAdding: .day, value: 1, to: Date())
        section1.startsAt = course.startsAt
        section1.endsAt = Calendar.current.date(byAdding: .day, value: -7, to: Date())
        section2.startsAt = course.startsAt
        section2.endsAt = course.endsAt

        let sectionsToDownloads = AutomatedDownloadsManager.sectionsToDownload(for: course)

        XCTAssertEqual(sectionsToDownloads, [section2])
    }

    func testOverlappingSectionsNoItemSection2() throws {
        section1.items = [try EntityCreationHelper.newVideoItem(in: context)]

        course.startsAt = Calendar.current.date(byAdding: .day, value: -14, to: Date())
        course.endsAt = Calendar.current.date(byAdding: .day, value: 1, to: Date())
        section1.startsAt = course.startsAt
        section1.endsAt = Calendar.current.date(byAdding: .day, value: -7, to: Date())
        section2.startsAt = course.startsAt
        section2.endsAt = course.endsAt

        let sectionsToDownloads = AutomatedDownloadsManager.sectionsToDownload(for: course)

        XCTAssertEqual(sectionsToDownloads, [])
    }

    func testBeforeCourseStart() throws {
        course.startsAt = Calendar.current.date(byAdding: .day, value: 1, to: Date())
        course.endsAt = Calendar.current.date(byAdding: .day, value: 14, to: Date())
        section1.startsAt = course.startsAt
        section1.endsAt = Calendar.current.date(byAdding: .day, value: 7, to: Date())
        section2.startsAt = section1.endsAt
        section2.endsAt = course.endsAt

        let sectionsToDownloads = AutomatedDownloadsManager.sectionsToDownload(for: course)

        XCTAssertEqual(sectionsToDownloads, [])
    }

    func testAfterCourseEnd() throws {
        course.startsAt = Calendar.current.date(byAdding: .day, value: -14, to: Date())
        course.endsAt = Calendar.current.date(byAdding: .day, value: -1, to: Date())
        section1.startsAt = course.startsAt
        section1.endsAt = Calendar.current.date(byAdding: .day, value: -7, to: Date())
        section2.startsAt = section1.endsAt
        section2.endsAt = course.endsAt

        let sectionsToDownloads = AutomatedDownloadsManager.sectionsToDownload(for: course)

        XCTAssertEqual(sectionsToDownloads, [])
    }

}
