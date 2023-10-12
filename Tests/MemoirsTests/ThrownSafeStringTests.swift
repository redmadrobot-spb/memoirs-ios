//
// ThrownSafeStringTests
// memoirs-ios
//
// Created by Alex Babaev on 12 October 2023.
// Copyright © 2023 Alex Babaev. All rights reserved.
//

import XCTest
@testable import Memoirs

class ThrownSafeStringTests: GenericTestCase {
    class ChangeableClass {
        var value: Int = 0

        init() {
        }

        func changeStateAndReturnSelf() throws -> Self {
            value += 1
            return self
        }
    }

    enum Problem: Error {
        case test
    }

    func testThrownInsideSafeString() throws {
        let memoir = VoidMemoir()
        let testClass: ChangeableClass = .init()
        try memoir.debug("Log value \(try testClass.changeStateAndReturnSelf())")
        XCTAssertEqual(testClass.value, 0)
    }
}
