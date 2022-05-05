//
// FilteringTests
// Memoirs
//
// Created by Alex Babaev on 19 November 2021.
// Copyright © 2021 Redmadrobot SPb. All rights reserved.
// Copyright © 2021 Alex Babaev. All rights reserved.
// License: MIT License, https://github.com/redmadrobot-spb/memoirs-ios/blob/main/LICENSE
//

import XCTest
import Foundation
@testable import Memoirs

// swiftlint:disable line_length
class FilteringTests: GenericTestCase {
    private var lastInterceptedOutput: String = ""

    override func setUp() {
        super.setUp()

        Output.logInterceptor = { memoir, item, logString in
            guard !logString.contains("Tracer: FilteringTests") && !logString.contains("Tracer: FilteringLabel") else { return }

            self.lastInterceptedOutput = logString
            print(" -----------------> Intercepted \(logString)")
        }
    }

    override func tearDown() {
        super.tearDown()

        Output.logInterceptor = nil
    }

    private let printMemoir = PrintMemoir()

    func testDefaultFiltering() async throws {
        var memoir = FilteringMemoir(
            memoir: printMemoir,
            defaultConfiguration: .init(minLevelShown: .info, applyToNestedByTrace: false, showEvents: false, showTracers: false, showMeasurements: false),
            configurationsByTracer: [:]
        )
        try await checkAllThings(memoir: memoir, infoLog: true, debugLog: false, event: false, tracer: false, measurement: false)

        memoir = FilteringMemoir(
            memoir: printMemoir,
            defaultConfiguration: .init(minLevelShown: .debug, applyToNestedByTrace: false, showEvents: false, showTracers: false, showMeasurements: false),
            configurationsByTracer: [:]
        )
        try await checkAllThings(memoir: memoir, infoLog: true, debugLog: true, event: false, tracer: false, measurement: false)

        memoir = FilteringMemoir(
            memoir: printMemoir,
            defaultConfiguration: .init(minLevelShown: .warning, applyToNestedByTrace: false, showEvents: true, showTracers: false, showMeasurements: false),
            configurationsByTracer: [:]
        )
        try await checkAllThings(memoir: memoir, infoLog: false, debugLog: false, event: true, tracer: false, measurement: false)

        memoir = FilteringMemoir(
            memoir: printMemoir,
            defaultConfiguration: .init(minLevelShown: .error, applyToNestedByTrace: false, showEvents: false, showTracers: true, showMeasurements: false),
            configurationsByTracer: [:]
        )
        try await checkAllThings(memoir: memoir, infoLog: false, debugLog: false, event: false, tracer: true, measurement: false)

        memoir = FilteringMemoir(
            memoir: printMemoir,
            defaultConfiguration: .init(minLevelShown: .disabled, applyToNestedByTrace: false, showEvents: false, showTracers: false, showMeasurements: true),
            configurationsByTracer: [:]
        )
        try await checkAllThings(memoir: memoir, infoLog: false, debugLog: false, event: false, tracer: false, measurement: true)

        memoir = FilteringMemoir(
            memoir: printMemoir,
            defaultConfiguration: .init(minLevelShown: .all, applyToNestedByTrace: false, showEvents: false, showTracers: false, showMeasurements: false),
            configurationsByTracer: [:]
        )
        try await checkAllThings(memoir: memoir, infoLog: true, debugLog: true, event: false, tracer: false, measurement: false)
    }

    private let allEnabledConfiguration: FilteringMemoir.Configuration = .init(minLevelShown: .all, applyToNestedByTrace: true, showEvents: true, showTracers: true, showMeasurements: true)
    private let allDisabledConfiguration: FilteringMemoir.Configuration = .init(minLevelShown: .disabled, applyToNestedByTrace: true, showEvents: false, showTracers: false, showMeasurements: false)

    func testTracerLabelFiltering() async throws {
        let filteringTracer: Tracer = .label("FilteringLabel")
        let nonFilteringTracer: Tracer = .label("NonFilteringLabel")
        let filteringMemoir = FilteringMemoir(
            memoir: printMemoir,
            defaultConfiguration: allDisabledConfiguration,
            configurationsByTracer: [
                filteringTracer: allEnabledConfiguration
            ]
        )
        let memoirShown = TracedMemoir(tracer: filteringTracer, memoir: filteringMemoir)
        let memoirHidden = TracedMemoir(tracer: nonFilteringTracer, memoir: filteringMemoir)

        try await checkAllThings(memoir: memoirShown, infoLog: true, debugLog: true, event: true, tracer: true, measurement: true)
        try await checkAllThings(memoir: memoirHidden, infoLog: false, debugLog: false, event: false, tracer: false, measurement: false)
    }

    func testTracerTypeFiltering() async throws {
        let filteringTracer: Tracer = tracer(for: self)
        let filteringMemoir = FilteringMemoir(
            memoir: printMemoir,
            defaultConfiguration: allDisabledConfiguration,
            configurationsByTracer: [
                filteringTracer: allEnabledConfiguration
            ]
        )
        let memoirShown = TracedMemoir(object: self, memoir: filteringMemoir)

        try await checkAllThings(memoir: memoirShown, infoLog: true, debugLog: true, event: true, tracer: true, measurement: true)
    }

    func testNestedTracerFiltering() async throws {
        let filteringTracer: Tracer = .label("FilteringLabel")
        let nestedTracer: Tracer = .label("NestedNotFilteringLabel")
        let filteringMemoir = FilteringMemoir(
            memoir: printMemoir,
            defaultConfiguration: allDisabledConfiguration,
            configurationsByTracer: [
                filteringTracer: allEnabledConfiguration
            ]
        )
        let memoirShown = TracedMemoir(tracer: filteringTracer, memoir: filteringMemoir)
        let memoirNested = memoirShown.with(tracer: nestedTracer)

        try await checkAllThings(memoir: memoirShown, infoLog: true, debugLog: true, event: true, tracer: true, measurement: true)
        try await checkAllThings(memoir: memoirNested, infoLog: true, debugLog: true, event: true, tracer: true, measurement: true)
    }

    private func checkAllThings(
        memoir: Memoir, infoLog: Bool, debugLog: Bool, event: Bool, tracer: Bool, measurement: Bool,
        file: StaticString = #file, line: UInt = #line
    ) async throws {
        let infoLogTest: SafeString = "INFO LOG TESTING"
        let debugLogTest: SafeString = "DEBUG LOG TESTING"
        let eventTest: String = "EVENT TESTING"
        let tracerTest: String = "TRACER TESTING"
        let measurementTest: String = "MEASUREMENT TESTING"
        try await check(memoir: memoir, item: .log(level: .info, message: infoLogTest), testValue: "\(infoLogTest)", mustPresent: infoLog, file: file, line: line)
        try await check(memoir: memoir, item: .log(level: .debug, message: debugLogTest), testValue: "\(debugLogTest)", mustPresent: debugLog, file: file, line: line)
        try await check(memoir: memoir, item: .event(name: eventTest), testValue: eventTest, mustPresent: event, file: file, line: line)
        try await check(memoir: memoir, item: .tracer(.label(tracerTest), isFinished: false), testValue: tracerTest, mustPresent: tracer, file: file, line: line)
        try await check(memoir: memoir, item: .tracer(.label(tracerTest), isFinished: true), testValue: tracerTest, mustPresent: tracer, file: file, line: line)
        try await check(memoir: memoir, item: .measurement(name: measurementTest, value: .int(239)), testValue: measurementTest, mustPresent: measurement, file: file, line: line)
    }

    private func check(
        memoir: Memoir, item: MemoirItem, testValue: String, mustPresent: Bool, file: StaticString = #file, line: UInt = #line
    ) async throws {
        memoir.append(
            item, meta: nil, tracers: [], timeIntervalSinceReferenceDate: Date.timeIntervalSinceReferenceDate,
            file: "", function: "", line: 0
        )
        try await Task.sleep(nanoseconds: 1_000_000_0)

        if mustPresent && !lastInterceptedOutput.contains(testValue) {
            XCTFail("Test string \"\(testValue)\" is NOT found in \"\(lastInterceptedOutput)\"", file: file, line: line)
        } else if !mustPresent && lastInterceptedOutput.contains(testValue) {
            XCTFail("Test string \"\(testValue)\" is FOUND (but not needed) in \"\(lastInterceptedOutput)\"", file: file, line: line)
        }
        lastInterceptedOutput = ""
    }
}
