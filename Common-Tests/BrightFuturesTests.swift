//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import XCTest

import BrightFutures

class BrightFuturesTests: XCTestCase {

    func testEarliestDeadlineChaining() {
        // given
        let expectation = self.expectation(description: "don't complete within two seconds")
        let startTime = CACurrentMediaTime()

        // when
        _ = Future<Void, Never>(value: ())
            .earliest(at: 1.second.fromNow)
            .andThen { _ in XCTAssert(CACurrentMediaTime() - startTime >= 1) }
            .earliest(at: 1.second.fromNow)
            .andThen { _ in
                XCTAssert(CACurrentMediaTime() - startTime >= 1)
                expectation.fulfill()
            }

        // then
        self.waitForExpectations(timeout: 3, handler: nil)
    }

    func testEarliestDeadlineChaining2() {
        // given
        let expectation = self.expectation(description: "don't complete within three seconds")
        let startTime = CACurrentMediaTime()

        // when
        _ = Future<Void, Never>(value: ())
            .earliest(at: 1.second.fromNow)
            .andThen { _ in XCTAssert(CACurrentMediaTime() - startTime >= 1) }
            .earliest(at: 2.second.fromNow)
            .andThen { _ in
                XCTAssert(CACurrentMediaTime() - startTime >= 2)
                expectation.fulfill()
            }

        // then
        self.waitForExpectations(timeout: 4, handler: nil)
    }

}
