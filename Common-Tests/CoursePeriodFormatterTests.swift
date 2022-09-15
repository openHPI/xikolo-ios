//
//  Created for xikolo-ios under GPL-3.0 license.
//  Copyright © HPI. All rights reserved.
//

import XCTest

@testable import Common

class CoursePeriodFormatterTests: XCTestCase {

    func testWithStartDateAndEndDate() {
        // given
        let distantPast = Date.distantPast
        let distantFuture = Date.distantFuture

        // when
        let labelText = CoursePeriodFormatter.string(fromStartDate: distantPast, endDate: distantFuture, withStyle: .normal)

        // then
        XCTAssertEqual(labelText, "Jan 1, 1 – Jan 1, 4001")
    }

    func testWithEndDateInPast() {
        // given
        let distantPast = Date.distantPast
        let afterDistantPast = Calendar.current.date(byAdding: .day, value: 1, to: distantPast)

        // when
        var labelText = CoursePeriodFormatter.string(fromStartDate: distantPast, endDate: afterDistantPast, withStyle: .normal)
        labelText = labelText.replacingOccurrences(of: "\u{00a0}", with: " ")

        // then
        XCTAssertEqual(labelText, "Self-paced since Jan 2, 1")
    }

    func testWithStartDateInPastAndNoEndDate() {
        // given
        let distantPast = Date.distantPast

        // when
        var labelText = CoursePeriodFormatter.string(fromStartDate: distantPast, endDate: nil, withStyle: .normal)
        labelText = labelText.replacingOccurrences(of: "\u{00a0}", with: " ")

        // then
        XCTAssertEqual(labelText, "Since Jan 1, 1")
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
        var labelText = CoursePeriodFormatter.string(fromStartDate: distantFuture, endDate: nil, withStyle: .normal)
        labelText = labelText.replacingOccurrences(of: "\u{00a0}", with: " ")

        // then
        XCTAssertEqual(labelText, "Beginning Jan 1, 4001")
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
