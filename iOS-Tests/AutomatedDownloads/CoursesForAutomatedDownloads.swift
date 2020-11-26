//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import XCTest
import CoreData
import Common
@testable import iOS

class CoursesForAutomatedDownloads: XCTestCase {

    private var context: NSManagedObjectContext!
    private var course: Course!

    override func setUpWithError() throws {
        let container = CoreDataTestHelper.newPersistentContainer()
        context = container.newBackgroundContext()

        let courseEntityDescription = NSEntityDescription.entity(forEntityName: "Course", in: context)!
        let enrollmentEntityDescription = NSEntityDescription.entity(forEntityName: "Enrollment", in: context)!

        course = Course(entity: courseEntityDescription, insertInto: context)
        course.id = UUID().uuidString
        course.startsAt = Calendar.current.date(byAdding: .day, value: 7, to: Date())
        course.endsAt = Calendar.current.date(byAdding: .day, value: 21, to: Date())
        course.status = "active"
        course.enrollment = Enrollment(entity: enrollmentEntityDescription, insertInto: context)
        course.automatedDownloadSettings = nil
    }

    func testWithSettings() throws {
        let fetchRequest = CourseHelper.FetchRequest.coursesForAutomatedDownloads
        let coursesForAutomatedDownloads = try context.fetch(fetchRequest)
        XCTAssertEqual(coursesForAutomatedDownloads, [course])
    }

    func testWithoutSettings() throws {
        course.automatedDownloadSettings = nil

        let fetchRequest1 = CourseHelper.FetchRequest.coursesWithAutomatedDownloads
        let coursesWithAutomatedDownloads = try context.fetch(fetchRequest1)
        XCTAssertEqual(coursesWithAutomatedDownloads, [])

        let fetchRequest2 = CourseHelper.FetchRequest.coursesForAutomatedDownloads
        let coursesForAutomatedDownloads = try context.fetch(fetchRequest2)
        XCTAssertEqual(coursesForAutomatedDownloads, [course])
    }

    func testWithoutEnrollment() throws {
        course.enrollment = nil

        let fetchRequest = CourseHelper.FetchRequest.coursesForAutomatedDownloads
        let coursesForAutomatedDownloads = try context.fetch(fetchRequest)
        XCTAssertEqual(coursesForAutomatedDownloads, [])
    }

    func testWithoutEndDate() throws {
        course.endsAt = nil

        let fetchRequest = CourseHelper.FetchRequest.coursesForAutomatedDownloads
        let coursesForAutomatedDownloads = try context.fetch(fetchRequest)
        XCTAssertEqual(coursesForAutomatedDownloads, [])
    }

    func testBeforeCourseStart() throws {
        course.startsAt = Calendar.current.date(byAdding: .day, value: 1, to: Date())
        course.endsAt = Calendar.current.date(byAdding: .day, value: 7, to: Date())

        let fetchRequest = CourseHelper.FetchRequest.coursesForAutomatedDownloads
        let coursesForAutomatedDownloads = try context.fetch(fetchRequest)
        XCTAssertEqual(coursesForAutomatedDownloads, [course])
    }

    func testDuringCoursePeriod() throws {
        course.startsAt = Calendar.current.date(byAdding: .day, value: -1, to: Date())
        course.endsAt = Calendar.current.date(byAdding: .day, value: 7, to: Date())

        let fetchRequest = CourseHelper.FetchRequest.coursesForAutomatedDownloads
        let coursesForAutomatedDownloads = try context.fetch(fetchRequest)
        XCTAssertEqual(coursesForAutomatedDownloads, [course])
    }

    func testAfterCourseEnd() throws {
        course.startsAt = Calendar.current.date(byAdding: .day, value: -7, to: Date())
        course.endsAt = Calendar.current.date(byAdding: .day, value: -1, to: Date())

        let fetchRequest = CourseHelper.FetchRequest.coursesForAutomatedDownloads
        let coursesForAutomatedDownloads = try context.fetch(fetchRequest)
        XCTAssertEqual(coursesForAutomatedDownloads, [])
    }

}
