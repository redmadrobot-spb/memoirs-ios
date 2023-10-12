//
// NonExecutabilityTests
// memoirs-ios
//
// Created by Alex Babaev on 12 October 2023.
// Copyright © 2023 Alex Babaev. All rights reserved.
//

import XCTest
@testable import Memoirs

class MemoirExecutabilityTests: GenericTestCase {
    class ChangeableClass {
        var value: Int = 0

        init() {
        }

        func changeStateAndReturnSelf() -> Self {
            value += 1
            return self
        }
    }

    enum Problem: Error {
        case test
    }

    func testNonExpandabilityWhenVoidMemoirUsedDebug() {
        let memoir = VoidMemoir()
        let testClass: ChangeableClass = .init()
        memoir.debug("Log value \(testClass.changeStateAndReturnSelf())")
        XCTAssertEqual(testClass.value, 0)
    }

    func testExpandabilityWhenNormalMemoirUsedDebug() {
        let memoir = PrintMemoir()
        let testClass: ChangeableClass = .init()
        memoir.debug("Log value \(testClass.changeStateAndReturnSelf())")
        XCTAssertEqual(testClass.value, 1)
    }

    func testNonExpandabilityWhenVoidMemoirUsedErrorWithError() {
        let memoir = VoidMemoir()
        let testClass: ChangeableClass = .init()
        memoir.error("Log value \(testClass.changeStateAndReturnSelf())", error: Problem.test)
        XCTAssertEqual(testClass.value, 0)
    }

    func testExpandabilityWhenNormalMemoirUsedErrorWithError() {
        let memoir = PrintMemoir()
        let testClass: ChangeableClass = .init()
        memoir.error("Log value \(testClass.changeStateAndReturnSelf())", error: Problem.test)
        XCTAssertEqual(testClass.value, 1)
    }

    func testNonExpandabilityWhenVoidMemoirUsedErrorWithoutError() {
        let memoir = VoidMemoir()
        let testClass: ChangeableClass = .init()
        memoir.error("Log value \(testClass.changeStateAndReturnSelf())")
        XCTAssertEqual(testClass.value, 0)
    }

    func testExpandabilityWhenNormalMemoirUsedErrorWithoutError() {
        let memoir = PrintMemoir()
        let testClass: ChangeableClass = .init()
        memoir.error("Log value \(testClass.changeStateAndReturnSelf())")
        XCTAssertEqual(testClass.value, 1)
    }
}
