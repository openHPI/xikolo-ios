//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import XCTest
import CoreData
import Common
@testable import iOS

@available(iOS 13, *)
class DateForNextAutomatedDownloadBackgroundProcessingTests: XCTestCase {

    private var context: NSManagedObjectContext!
    private var course: Course!
    private var section1: CourseSection!
    private var section2: CourseSection!

    override func setUpWithError() throws {
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

    func testBeforeCourseStart() throws {
        course.startsAt = Calendar.current.date(byAdding: .day, value: 7, to: Date())
        course.endsAt = Calendar.current.date(byAdding: .day, value: 21, to: Date())
        section1.startsAt = Calendar.current.date(byAdding: .day, value: 7, to: Date())
        section1.endsAt = Calendar.current.date(byAdding: .day, value: 14, to: Date())
        section2.startsAt = Calendar.current.date(byAdding: .day, value: 14, to: Date())
        section2.endsAt = Calendar.current.date(byAdding: .day, value: 21, to: Date())

        let dateForNextBackgroundProcessing = AutomatedDownloadsManager.dateForNextBackgroundProcessing(in: context)

        XCTAssertEqual(dateForNextBackgroundProcessing, course.startsAt)
    }

    func testBeforeNextSection() throws {
        course.startsAt = Calendar.current.date(byAdding: .day, value: -2, to: Date())
        course.endsAt = Calendar.current.date(byAdding: .day, value: 21, to: Date())
        section1.startsAt = Calendar.current.date(byAdding: .day, value: -2, to: Date())
        section1.endsAt = Calendar.current.date(byAdding: .day, value: 14, to: Date())
        section2.startsAt = Calendar.current.date(byAdding: .day, value: 14, to: Date())
        section2.endsAt = Calendar.current.date(byAdding: .day, value: 21, to: Date())

        let dateForNextBackgroundProcessing = AutomatedDownloadsManager.dateForNextBackgroundProcessing(in: context)

        XCTAssertEqual(dateForNextBackgroundProcessing, section2.startsAt)
    }

    func testBeforeCourseEnd() throws {
        course.startsAt = Calendar.current.date(byAdding: .day, value: -9, to: Date())
        course.endsAt = Calendar.current.date(byAdding: .day, value: 8, to: Date())
        section1.startsAt = Calendar.current.date(byAdding: .day, value: -9, to: Date())
        section1.endsAt = Calendar.current.date(byAdding: .day, value: -2, to: Date())
        section2.startsAt = Calendar.current.date(byAdding: .day, value: -2, to: Date())
        section2.endsAt = Calendar.current.date(byAdding: .day, value: 7, to: Date())

        let dateForNextBackgroundProcessing = AutomatedDownloadsManager.dateForNextBackgroundProcessing(in: context)

        XCTAssertEqual(dateForNextBackgroundProcessing, course.endsAt)
    }

    func testAfterCourseEnd() throws {
        course.startsAt = Calendar.current.date(byAdding: .day, value: -16, to: Date())
        course.endsAt = Calendar.current.date(byAdding: .day, value: -2, to: Date())
        section1.startsAt = Calendar.current.date(byAdding: .day, value: -16, to: Date())
        section1.endsAt = Calendar.current.date(byAdding: .day, value: -9, to: Date())
        section2.startsAt = Calendar.current.date(byAdding: .day, value: -9, to: Date())
        section2.endsAt = Calendar.current.date(byAdding: .day, value: -3, to: Date())

        let dateForNextBackgroundProcessing = AutomatedDownloadsManager.dateForNextBackgroundProcessing(in: context)

        XCTAssertNil(dateForNextBackgroundProcessing)
    }

    func testNoEnrollments() throws {
        course.enrollment = nil

        let dateForNextBackgroundProcessing = AutomatedDownloadsManager.dateForNextBackgroundProcessing(in: context)

        XCTAssertNil(dateForNextBackgroundProcessing)
    }

    func testNoCoursesWithAutomatedDownloads() throws {
        course.automatedDownloadSettings = nil

        let dateForNextBackgroundProcessing = AutomatedDownloadsManager.dateForNextBackgroundProcessing(in: context)

        XCTAssertNil(dateForNextBackgroundProcessing)
    }

}
