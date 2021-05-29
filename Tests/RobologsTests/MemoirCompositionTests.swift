//
// MemoirCompositionTests
// Memoirs
//
// Created by Alex Babaev on 10 May 2021.
// Copyright © 2021 Redmadrobot SPb. All rights reserved.
//

import XCTest
@testable import Robologs

class MemoirCompositionTests: GenericTestCase {
    let printMemoir = PrintMemoir()

    func testLoggingLabel() throws {
        let memoir = TracedMemoir(label: "[Memoir]", memoir: printMemoir)

        memoir.debug("Test log 1")
        guard let result1 = logResult() else { throw Problem.noLogFromMemoir(memoir) }

        if !result1.contains("[Memoir]") || !(result1.contains("Test log 1")) {
            throw Problem.wrongLabelInLog(memoir)
        }

        memoir.debug("Test log 2")
        guard let result2 = logResult() else { throw Problem.noLogFromMemoir(memoir) }

        if !result2.contains("[Memoir]") || !(result2.contains("Test log 2")) {
            throw Problem.wrongLabelInLog(memoir)
        }
    }

    func testNestedLabeledMemoirs() throws {
        let innerMemoir = TracedMemoir(label: "[Inner]", memoir: printMemoir)
        let memoir = TracedMemoir(label: "[Outer]", memoir: innerMemoir)

        memoir.debug("Test log")
        guard let result = logResult() else { throw Problem.noLogFromMemoir(memoir) }

        if !result.contains("[Outer]") {
            throw Problem.wrongLabelInLog(memoir)
        }
    }

    func testNestedMemoirs() throws {
        let tracer1: Tracer = .label("Tracer 1")
        let tracer2: Tracer = .label("Tracer 2")

        let printMemoir = PrintMemoir()

        let tracedMemoir1 = TracedMemoir(tracer: tracer1, meta: [:], memoir: printMemoir)
        let tracedMemoir2 = TracedMemoir(tracer: tracer2, meta: [:], memoir: tracedMemoir1)

        tracedMemoir2.debug("Test log")
        guard let result = logResult() else { throw Problem.noLogFromMemoir(tracedMemoir2) }

        if !result.contains("Tracer 1") || !result.contains("Tracer 2") {
            throw Problem.wrongScopeInLog(tracedMemoir2)
        }
    }
}
