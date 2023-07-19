//
// ContextTests
// memoirs-ios
//
// Created by Alex Babaev on 09 September 2022.
// Copyright © 2022 Alex Babaev. All rights reserved.
//

import Foundation
import Memoirs
import XCTest

class ContextTests: XCTestCase {
    func testTaskLocalInitialization() async throws {
        var tracer: Tracer?
        let initialValue = await TaskLocalMemoir.localValue?.tracer.string
        XCTAssertNil(initialValue)

        let memoir = TracedMemoir(tracer: .label("TestTracer"), memoir: PrintMemoir())
        await TaskLocalMemoir.$localValue.withValue(memoir) { tracer = await TaskLocalMemoir.localValue?.tracer }

        XCTAssertEqual(tracer?.string, "TestTracer")
    }

    func testTracing() async throws {
        class TestTraceable {
            func test() async throws -> String? {
                await Tracing.with(.label("NewTracer")) { memoir in await (memoir as? TracedMemoir)?.tracer.string }
            }
        }

        let testTraceable = TestTraceable()
        let memoir = TracedMemoir(tracer: .label("TestTracer"), memoir: PrintMemoir())
        let result = try await TaskLocalMemoir.$localValue.withValue(memoir) { try await testTraceable.test() }

        XCTAssertEqual(result, "NewTracer")
    }

    func testDetachedTracing() async throws {
        class TestTraceable {
            let expectation = XCTestExpectation(description: "Detached Tracing")
            var result: String?

            func test() async throws {
                Tracing.withDetached(.label("DetachedTracer")) { memoir in
                    self.result = await (memoir as? TracedMemoir)?.tracer.string
                    self.expectation.fulfill()
                }
            }
        }

        let testTraceable = TestTraceable()
        let memoir = TracedMemoir(tracer: .label("TestTracer"), memoir: PrintMemoir())
        try await TaskLocalMemoir.$localValue.withValue(memoir) { try await testTraceable.test() }
        await fulfillment(of: [ testTraceable.expectation ], timeout: 5)

        XCTAssertEqual(testTraceable.result, "DetachedTracer")
    }
}
