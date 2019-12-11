//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import XCTest

@testable import Common

class CourseItemBase62UUIDTests: XCTestCase {

    func testBase62UUIDforUUID() {
        // given
        let uuid = "45336b3b-4ef3-4b5a-b89f-b2d6e6361119"

        // when
        let base62UUID = CourseItem.base62UUID(forUUID: uuid)

        // then
        XCTAssertEqual(base62UUID, "26zY52tsj0TTA7iMhfNrCN")
    }

    func testBase62UUIDforCompactUUID() {
        // given
        let uuid = "45336b3b4ef34b5ab89fb2d6e6361119"

        // when
        let base62UUID = CourseItem.base62UUID(forUUID: uuid)

        // then
        XCTAssertEqual(base62UUID, "26zY52tsj0TTA7iMhfNrCN")
    }

    func testBase62UUIDforUUIDWithInvalidCharacter() {
        // given
        let uuid = "45336b3b-4ef3-4b5a-b89f-b2d6e636111h" // `h` at the end of the string

        // when
        let base62UUID = CourseItem.base62UUID(forUUID: uuid)

        // then
        XCTAssertNil(base62UUID)
    }

    func testUUIDforBase62UUID() {
        // given
        let base62UUID = "26zY52tsj0TTA7iMhfNrCN"

        // when
        let uuid = CourseItem.uuid(forBase62UUID: base62UUID)

        // then
        XCTAssertEqual(uuid, "45336b3b-4ef3-4b5a-b89f-b2d6e6361119")
    }

    func testUUIDforTooShortBase62UUID() {
        // given
        let base62UUID = "26zY52tsj0TTA7iMhfNrC" // one character too short

        // when
        let uuid = CourseItem.uuid(forBase62UUID: base62UUID)

        // then
        XCTAssertNil(uuid)
    }

    func testUUIDforTooLongBase62UUID() {
        // given
        let base62UUID = "26zY52tsj0TTA7iMhfNrCN1" // additional `1` at the end of the string, one character too long

        // when
        let uuid = CourseItem.uuid(forBase62UUID: base62UUID)

        // then
        XCTAssertNil(uuid)
    }

    func testUUIDforBase62UUIDWithInvalidCharacter() {
        // given
        let base62UUID = "26zY52tsj0TTA7iMhfNrC!" // `!` at the end of the string

        // when
        let uuid = CourseItem.uuid(forBase62UUID: base62UUID)

        // then
        XCTAssertNil(uuid)
    }

}
