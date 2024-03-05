//
// TaskTracingTests
// memoirs-ios
//
// Created by Alex Babaev on 09 September 2022.
// Copyright © 2022 Alex Babaev. All rights reserved.
//

import Foundation
import Memoirs
import XCTest
#if canImport(MemoirMacros)
import MemoirMacros

private let rootMemoir = PrintMemoir(tracerFilter: { _ in true })

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
class MacroTests: XCTestCase {
    func testMacros() async {
        let testStruct = TestStruct()
        testStruct.testMemoirUsage()
        await testStruct.testAsyncTracing()
        await Tracing.with(root: $createLocalMemoir()) { _ in
            await testStruct.callAsyncTracingFunction()
        }
    }
}
#endif
