//
// TracerChangesTests
// Memoirs
//
// Created by Alex Babaev on 10 May 2021.
// Copyright © 2021 Redmadrobot SPb. All rights reserved.
//

import XCTest
@testable import Memoirs

class TracerChangesTests: GenericTestCase {
    let printMemoir = PrintMemoir(time: .formatter(PrintMemoir.fullDateFormatter), shortTracers: false) { _ in true }

    func testChangeTracer() throws {
        let memoir = TracedMemoir(label: "First", memoir: printMemoir)

        memoir.debug("Test log 1")
        guard let result1 = logResult() else { throw Problem.noLogFromMemoir(memoir) }

        if !result1.contains("First") || !(result1.contains("Test log 1")) {
            throw Problem.wrongLabelInLog(memoir)
        }

        memoir.updateTracer(to: .label("Second"))
        memoir.debug("Test log 2")

        guard let result2 = logResult() else { throw Problem.noLogFromMemoir(memoir) }

        if result2.contains("First") || !result2.contains("Second") || !(result2.contains("Test log 2")) {
            throw Problem.wrongLabelInLog(memoir)
        }
    }

    func testChangeParentTracer() throws {
        let memoirParent = TracedMemoir(label: "First", memoir: printMemoir)
        let memoir = TracedMemoir(label: "Second", memoir: memoirParent)

        memoir.debug("Test log 1")
        guard let result1 = logResult() else { throw Problem.noLogFromMemoir(memoir) }

        if !result1.contains("First") || !result1.contains("Second") || !(result1.contains("Test log 1")) {
            throw Problem.wrongLabelInLog(memoir)
        }

        memoirParent.updateTracer(to: .label("Third"))
        memoir.debug("Test log 2")

        guard let result2 = logResult() else { throw Problem.noLogFromMemoir(memoir) }

        if result2.contains("First") || !result2.contains("Second") || !result2.contains("Third") || !(result2.contains("Test log 2")) {
            throw Problem.wrongLabelInLog(memoir)
        }
    }
}
