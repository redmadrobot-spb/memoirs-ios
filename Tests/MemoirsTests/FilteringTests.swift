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
            self.lastInterceptedOutput = logString
        }
    }

    private let printMemoir = PrintMemoir()

    func testDefaultFiltering() {
        var memoir = FilteringMemoir(
            memoir: printMemoir,
            defaultConfiguration: .init(minLevelShown: .info, applyToNestedByTrace: false, showEvents: false, showTracers: false, showMeasurements: false),
            configurationsByTracer: [:]
        )
        checkAllThings(memoir: memoir, infoLog: true, debugLog: false, event: false, tracer: false, measurement: false)

        memoir = FilteringMemoir(
            memoir: printMemoir,
            defaultConfiguration: .init(minLevelShown: .debug, applyToNestedByTrace: false, showEvents: false, showTracers: false, showMeasurements: false),
            configurationsByTracer: [:]
        )
        checkAllThings(memoir: memoir, infoLog: true, debugLog: true, event: false, tracer: false, measurement: false)

        memoir = FilteringMemoir(
            memoir: printMemoir,
            defaultConfiguration: .init(minLevelShown: .warning, applyToNestedByTrace: false, showEvents: true, showTracers: false, showMeasurements: false),
            configurationsByTracer: [:]
        )
        checkAllThings(memoir: memoir, infoLog: false, debugLog: false, event: true, tracer: false, measurement: false)

        memoir = FilteringMemoir(
            memoir: printMemoir,
            defaultConfiguration: .init(minLevelShown: .error, applyToNestedByTrace: false, showEvents: false, showTracers: true, showMeasurements: false),
            configurationsByTracer: [:]
        )
        checkAllThings(memoir: memoir, infoLog: false, debugLog: false, event: false, tracer: true, measurement: false)

        memoir = FilteringMemoir(
            memoir: printMemoir,
            defaultConfiguration: .init(minLevelShown: .disabled, applyToNestedByTrace: false, showEvents: false, showTracers: false, showMeasurements: true),
            configurationsByTracer: [:]
        )
        checkAllThings(memoir: memoir, infoLog: false, debugLog: false, event: false, tracer: false, measurement: true)

        memoir = FilteringMemoir(
            memoir: printMemoir,
            defaultConfiguration: .init(minLevelShown: .all, applyToNestedByTrace: false, showEvents: false, showTracers: false, showMeasurements: false),
            configurationsByTracer: [:]
        )
        checkAllThings(memoir: memoir, infoLog: true, debugLog: true, event: false, tracer: false, measurement: false)
    }

    private let allEnabledConfiguration: FilteringMemoir.Configuration = .init(minLevelShown: .all, applyToNestedByTrace: true, showEvents: true, showTracers: true, showMeasurements: true)
    private let allDisabledConfiguration: FilteringMemoir.Configuration = .init(minLevelShown: .disabled, applyToNestedByTrace: true, showEvents: false, showTracers: false, showMeasurements: false)

    func testTracerLabelFiltering() {
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

        checkAllThings(memoir: memoirShown, infoLog: true, debugLog: true, event: true, tracer: true, measurement: true)
        checkAllThings(memoir: memoirHidden, infoLog: false, debugLog: false, event: false, tracer: false, measurement: false)
    }

    func testTracerTypeFiltering() {
        let filteringTracer: Tracer = tracer(for: self)
        let filteringMemoir = FilteringMemoir(
            memoir: printMemoir,
            defaultConfiguration: allDisabledConfiguration,
            configurationsByTracer: [
                filteringTracer: allEnabledConfiguration
            ]
        )
        let memoirShown = TracedMemoir(object: self, memoir: filteringMemoir)

        checkAllThings(memoir: memoirShown, infoLog: true, debugLog: true, event: true, tracer: true, measurement: true)
    }

    func testNestedTracerFiltering() {
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

        checkAllThings(memoir: memoirShown, infoLog: true, debugLog: true, event: true, tracer: true, measurement: true)
        checkAllThings(memoir: memoirNested, infoLog: true, debugLog: true, event: true, tracer: true, measurement: true)
    }

    private func checkAllThings(memoir: Memoir, infoLog: Bool, debugLog: Bool, event: Bool, tracer: Bool, measurement: Bool) {
        let infoLogTest: SafeString = "INFO LOG TESTING"
        let debugLogTest: SafeString = "DEBUG LOG TESTING"
        let eventTest: String = "EVENT TESTING"
        let tracerTest: String = "TRACER TESTING"
        let measurementTest: String = "MEASUREMENT TESTING"
        check(memoir: memoir, item: .log(level: .info, message: infoLogTest), testValue: "\(infoLogTest)", mustPresent: infoLog)
        check(memoir: memoir, item: .log(level: .debug, message: debugLogTest), testValue: "\(debugLogTest)", mustPresent: debugLog)
        check(memoir: memoir, item: .event(name: eventTest), testValue: eventTest, mustPresent: event)
        check(memoir: memoir, item: .tracer(.label(tracerTest), isFinished: false), testValue: tracerTest, mustPresent: tracer)
        check(memoir: memoir, item: .tracer(.label(tracerTest), isFinished: true), testValue: tracerTest, mustPresent: tracer)
        check(memoir: memoir, item: .measurement(name: measurementTest, value: .int(239)), testValue: measurementTest, mustPresent: measurement)
    }

    private func check(memoir: Memoir, item: MemoirItem, testValue: String, mustPresent: Bool) {
        memoir.append(item, meta: nil, tracers: [], date: Date(), file: "", function: "", line: 0)
        if mustPresent && !lastInterceptedOutput.contains(testValue) {
            XCTFail("Test string \"\(testValue)\" is NOT found in \"\(lastInterceptedOutput)\"")
        } else if !mustPresent && lastInterceptedOutput.contains(testValue) {
            XCTFail("Test string \"\(testValue)\" is FOUND (but should not be there) in \"\(lastInterceptedOutput)\"")
        }
        lastInterceptedOutput = ""
    }
}
