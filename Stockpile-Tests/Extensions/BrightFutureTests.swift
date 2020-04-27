//
//  Created for xikolo-ios under MIT license.
//  Copyright © HPI. All rights reserved.
//

import BrightFutures
import XCTest

@testable import Stockpile

class BrightFutureTests: XCTestCase {

    enum TestError: Error {
        case someError
    }

    func testInjectSuccess() {
        // Given
        let value = true
        let outerFuture = Future<Bool, Error>(value: value)
        let innerResult = Result<Void, Error>(value: ())

        let outerExpectation = self.expectation(description: "outer")
        let innerExpectation = self.expectation(description: "inner")

        // When
        let resultFuture = outerFuture.inject {
            innerExpectation.fulfill()
            return innerResult
        }.onComplete { _ in
            outerExpectation.fulfill()
        }

        waitForExpectations(timeout: 0.3, handler: nil)

        // Then
        XCTAssertTrue(resultFuture.isSuccess)
        let value = XCTUnwrap(resultFuture.value)
        XCTAssertTrue(value)
    }

    func testInjectOuterFailure() {
        // Given
        let error: TestError = .someError
        let outerFuture = Future<Bool, TestError>(error: error)
        let innerResult = Result<Void, TestError>(value: ())

        let outerExpectation = self.expectation(description: "outer")
        let innerExpectation = self.expectation(description: "inner")
        innerExpectation.isInverted = true

        // When
        let resultFuture = outerFuture.inject {
            innerExpectation.fulfill()
            return innerResult
        }.onComplete { _ in
            outerExpectation.fulfill()
        }

        waitForExpectations(timeout: 0.3, handler: nil)

        // Then
        XCTAssertTrue(resultFuture.isFailure)
        XCTAssertEqual(resultFuture.error, error)
    }

    func testInjectInnerFailure() {
        // Given
        let error: TestError = .someError
        let outerFuture = Future<Bool, TestError>(value: true)
        let innerResult = Result<Void, TestError>(error: error)

        let outerExpectation = self.expectation(description: "outer")
        let innerExpectation = self.expectation(description: "inner")

        // When
        let resultFuture = outerFuture.inject {
            innerExpectation.fulfill()
            return innerResult
        }.onComplete { _ in
            outerExpectation.fulfill()
        }

        waitForExpectations(timeout: 0.3, handler: nil)

        // Then
        XCTAssertTrue(resultFuture.isFailure)
        XCTAssertEqual(resultFuture.error, error)
    }

}
