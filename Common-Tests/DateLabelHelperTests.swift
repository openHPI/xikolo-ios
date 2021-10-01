//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import XCTest

@testable import Common

class DateLabelHelperTests: XCTestCase {

    func testWithStartDateAndEndDate() {
        // given
        let distantPast = Date.distantPast
        let distantFuture = Date.distantFuture

        // when
        let labelText = CoursePeriodFormatter.string(fromStartDate: distantPast, endDate: distantFuture, withStyle: .normal)

        // then
        XCTAssertEqual(labelText, "January 1, 1 – January 1, 4001")
    }

    func testWithEndDateInPast() {
        // given
        let distantPast = Date.distantPast
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())

        // when
        let labelText = CoursePeriodFormatter.string(fromStartDate: distantPast, endDate: yesterday, withStyle: .normal)

        // then
        XCTAssertEqual(labelText, "Self-paced")
    }

    func testWithStartDateInPastAndNoEndDate() {
        // given
        let distantPast = Date.distantPast

        // when
        let labelText = CoursePeriodFormatter.string(fromStartDate: distantPast, endDate: nil, withStyle: .normal)

        // then
        XCTAssertEqual(labelText, "Since January 1, 1")
    }

    func testWithStartDateInPastAndNoEndDateInWhoStyle() {
        // given
        let distantPast = Date.distantPast

        // when
        let labelText = CoursePeriodFormatter.string(fromStartDate: distantPast, endDate: nil, withStyle: .who)

        // then
        XCTAssertEqual(labelText, "Self-paced")
    }

    func testWithStartDateInFutureAndNoEndDate() {
        // given
        let distantFuture = Date.distantFuture

        // when
        let labelText = CoursePeriodFormatter.string(fromStartDate: distantFuture, endDate: nil, withStyle: .normal)

        // then
        XCTAssertEqual(labelText, "Beginning January 1, 4001")
    }

    func testWithStartDateInFutureAndNoEndDateInWhoStyle() {
        // given
        let distantFuture = Date.distantFuture

        // when
        let labelText = CoursePeriodFormatter.string(fromStartDate: distantFuture, endDate: nil, withStyle: .who)

        // then
        XCTAssertEqual(labelText, "Coming soon")
    }

    func testWithOnlyEndDate() {
        // given
        let distantFuture = Date.distantFuture

        // when
        let labelText = CoursePeriodFormatter.string(fromStartDate: nil, endDate: distantFuture, withStyle: .normal)

        // then
        XCTAssertEqual(labelText, "Coming soon")
    }

    func testWithNoDates() {
        // when
        let labelText = CoursePeriodFormatter.string(fromStartDate: nil, endDate: nil, withStyle: .normal)

        // then
        XCTAssertEqual(labelText, "Coming soon")
    }

}
