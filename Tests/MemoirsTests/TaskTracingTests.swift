//
// TaskTracingTests
// memoirs-ios
//
// Created by Alex Babaev on 09 September 2022.
// Copyright © 2022 Alex Babaev. All rights reserved.
//

import Foundation
import Memoirs
import MemoirMacros
import XCTest

let rootMemoir = PrintMemoir(tracerFilter: { _ in true })

@available(iOS 15.0, *)
@WithMemoir(rootMemoir)
class TestClass {
    func testMemoirUsage() {
        let memoir = $createLocalMemoir()
        memoir.debug("Debug Class 1")
    }

    func testAsyncTracing() async {
        let memoir = $createLocalMemoir()
        memoir.debug("Async Debug Class 1")
    }
}

@available(iOS 15.0, *)
@WithMemoir(rootMemoir)
struct TestStruct {
    func testMemoirUsage() {
        let memoir = $createLocalMemoir()
        memoir.debug("Debug Struct 1")
    }

    func testAsyncTracing() async {
        let memoir = $createLocalMemoir()
        memoir.debug("Async Debug Struct 1")
    }

    func callAsyncTracingFunction() async {
        let memoir = $createLocalMemoir()
        memoir.debug("Async Debug Struct 2")

        await Tracing.with(Self.$typeTracer) { _ in
            let clazz = TestClass()
            clazz.testMemoirUsage()
            await clazz.testAsyncTracing()
        }
    }
}

@available(iOS 15, *)
@WithMemoir(rootMemoir)
class TaskTracingTests: XCTestCase {
    func testMacros() async {
        let testStruct = TestStruct()
        testStruct.testMemoirUsage()
        await testStruct.testAsyncTracing()
        await Tracing.with(root: $createLocalMemoir()) { _ in
            await testStruct.callAsyncTracingFunction()
        }
    }

    func testTaskLocalInitialization() async throws {
        var tracer: Tracer?
        let initialValue = await Tracing.localValue?.tracer.string
        XCTAssertNil(initialValue)

        let memoir = TracedMemoir(tracer: .label("TestTracer"), memoir: PrintMemoir())
        await Tracing.$localValue.withValue(memoir) { tracer = await Tracing.localValue?.tracer }

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
        let result = try await Tracing.$localValue.withValue(memoir) { try await testTraceable.test() }

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
        try await Tracing.$localValue.withValue(memoir) { try await testTraceable.test() }
        await fulfillment(of: [ testTraceable.expectation ], timeout: 5)

        XCTAssertEqual(testTraceable.result, "DetachedTracer")
    }
}
