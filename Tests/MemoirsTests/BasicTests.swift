//
// BasicTests
// Memoirs
//
// Created by Alex Babaev on 05 May 2021.
// Copyright © 2021 Redmadrobot SPb. All rights reserved.
// Copyright © 2021 Alex Babaev. All rights reserved.
// License: MIT License, https://github.com/redmadrobot-spb/memoirs-ios/blob/main/LICENSE
//

import XCTest
import Foundation
@testable import Memoirs

// swiftlint:disable line_length
class BasicTests: GenericTestCase {
    private let basicMemoirsWithoutCensoring: [Memoir] = [
        PrintMemoir(),
        NSLogMemoir(isSensitive: false),
        OSLogMemoir(subsystem: "Test", isSensitive: false),
    ]

    public func testAllLogOverloads() {
        let memoir: Memoir = PrintMemoir(time: .formatter(PrintMemoir.fullDateFormatter))
        let tracer: Tracer = .label("TestTracer")

        memoir.log(level: .info, "Test log 1", meta: [ "Test Key": "Test Value" ], tracers: [ tracer ], date: Date(timeIntervalSince1970: 239), file: "file", function: "function", line: 239)
        guard let result = logResult(), result.contains("1970-01-01 03:03:59.000"), result.contains("TestTracer"), result.contains("Test Key: Test Value"), result.contains("Test log 1") else {
            return XCTFail("Can't call log(level:_:label:scopes:meta:date:file:function:line:)")
        }

        memoir.log(level: .info, "Test log 2", meta: [ "Test Key": "Test Value" ], tracers: [ tracer ], date: Date(timeIntervalSince1970: 239), file: "file", function: "function")
        guard let result = logResult(), result.contains("1970-01-01 03:03:59.000"), result.contains("TestTracer"), result.contains("Test Key: Test Value"), result.contains("Test log 2") else { // TODO: Check date and meta
            return XCTFail("Can't call log(level:_:label:scopes:meta:date:file:function:)")
        }

        memoir.log(level: .info, "Test log 3", meta: [ "Test Key": "Test Value" ], tracers: [ tracer ], date: Date(timeIntervalSince1970: 239), file: "file")
        guard let result = logResult(), result.contains("1970-01-01 03:03:59.000"), result.contains("TestTracer"), result.contains("Test Key: Test Value"), result.contains("Test log 3") else { // TODO: Check date and meta
            return XCTFail("Can't call log(level:_:label:scopes:meta:date:file:)")
        }

        memoir.log(level: .info, "Test log 4", meta: [ "Test Key": "Test Value" ], tracers: [ tracer ], date: Date(timeIntervalSince1970: 239))
        guard let result = logResult(), result.contains("1970-01-01 03:03:59.000"), result.contains("TestTracer"), result.contains("Test Key: Test Value"), result.contains("Test log 4") else { // TODO: Check date and meta
            return XCTFail("Can't call log(level:_:label:scopes:meta:date:)")
        }

        memoir.log(level: .info, "Test log 5", meta: [ "Test Key": "Test Value" ], tracers: [ tracer ])
        guard let result = logResult(), result.contains("TestTracer"), result.contains("Test Key: Test Value"), result.contains("Test log 5") else { // TODO: Check date and meta
            return XCTFail("Can't call log(level:_:label:scopes:meta:)")
        }

        memoir.log(level: .info, "Test log 6", tracers: [ tracer ])
        guard let result = logResult(), result.contains("TestTracer"), result.contains("Test log 6") else { // TODO: Check date and meta
            return XCTFail("Can't call log(level:_:label:scopes:meta:)")
        }
    }

    func testConfigureOutput() throws {
        let levelStrings: [LogLevel: String] = [
            .verbose: LogLevel.verbose.testValue,
            .debug: LogLevel.debug.testValue,
            .info: LogLevel.info.testValue,
            .warning: LogLevel.warning.testValue,
            .error: LogLevel.error.testValue,
            .critical: LogLevel.critical.testValue,
        ]
        LogLevel.configure(
            stringForVerbose: levelStrings[.verbose]!,
            stringForDebug: levelStrings[.debug]!,
            stringForInfo: levelStrings[.info]!,
            stringForWarning: levelStrings[.warning]!,
            stringForError: levelStrings[.error]!,
            stringForCritical: levelStrings[.critical]!
        )

        let memoir = PrintMemoir()
        for (level, string) in levelStrings {
            var probe = simpleProbe(memoir: memoir)
            probe.level = level
            let log = try expectLog(probe: probe)
            if !log.contains(string) {
                throw Problem.noLabelInLog(memoir)
            }
        }
    }

    func testLabelAndMessageInLoggers() throws {
        for memoir: Memoir in basicMemoirsWithoutCensoring {
            let probe = simpleProbe(memoir: memoir)
            let log = try expectLog(probe: probe)
            if !log.contains(probe.label) { throw Problem.noLabelInLog(memoir) }
            if !log.contains(probe.censoredMessage) { throw Problem.noMessageInLog(memoir) }
        }
    }

    func testLabeledLogger() throws {
        let allLevels: [LogLevel] = [ .verbose, .debug, .info, .warning, .error, .critical ]
        let printMemoir = PrintMemoir()
        let memoir = TracedMemoir(label: "label_\(Int.random(in: Int.min ... Int.max))", memoir: printMemoir)
        for level in allLevels {
            var probe = simpleProbe(memoir: memoir)
            probe.level = level
            try logShouldPresent(probe: probe, memoir: memoir)
        }
    }

    func testScopedLogger() throws {
        let allLevels: [LogLevel] = [ .verbose, .debug, .info, .warning, .error, .critical ]
        let printMemoir = PrintMemoir()
        let tracer: Tracer = .label("tracer_\(Int.random(in: Int.min ... Int.max))")
        let memoir = TracedMemoir(tracer: tracer, meta: [:], memoir: printMemoir)
        for level in allLevels {
            var probe = simpleProbe(memoir: memoir)
            probe.level = level
            try logShouldPresent(probe: probe, memoir: memoir)
        }
    }

    func testLabeledScopedLogger() throws {
        let allLevels: [LogLevel] = [ .verbose, .debug, .info, .warning, .error, .critical ]
        let printMemoir = PrintMemoir()
        let tracer: Tracer = .label("tracer_\(Int.random(in: Int.min ... Int.max))")
        let memoir = TracedMemoir(
            label: "label_\(Int.random(in: Int.min ... Int.max))",
            memoir: TracedMemoir(tracer: tracer, meta: [:], memoir: printMemoir)
        )
        for level in allLevels {
            var probe = simpleProbe(memoir: memoir)
            probe.tracers = [ tracer ]
            probe.level = level
            try logShouldPresent(probe: probe, memoir: memoir)
        }
    }

    func testFilteringLevels() throws {
        let allConfigurationLevels: [(FilteringMemoir.Configuration.Level, Int)] =
            [
                (.all, -1),
                (.verbose, 0),
                (.debug, 1),
                (.info, 2),
                (.warning, 3),
                (.error, 4),
                (.critical, 5),
                (.disabled, Int.max),
            ]
        let allLevels: [(LogLevel, Int)] =
            [
                (.verbose, 0),
                (.debug, 1),
                (.info, 2),
                (.warning, 3),
                (.error, 4),
                (.critical, 5),
            ]
        for (configurationLevel, configurationIndex) in allConfigurationLevels {
            let memoir = FilteringMemoir(
                memoir: PrintMemoir(),
                defaultConfiguration: .init(minLevelShown: configurationLevel),
                configurationsByTracer: [:]
            )
            for (level, levelIndex) in allLevels {
                try checkLog(memoir: memoir, logShouldPresent: levelIndex >= configurationIndex) { $0.level = level }
            }
        }
    }

    func testFilteringLoggerOnAll() throws {
        let memoir = FilteringMemoir(
            memoir: PrintMemoir(),
            defaultConfiguration: .init(minLevelShown: .all),
            configurationsByTracer: [:]
        )
        try checkLog(memoir: memoir, logShouldPresent: true)
    }

    func testFilteringLoggerOffAll() throws {
        let memoir = FilteringMemoir(
            memoir: PrintMemoir(),
            defaultConfiguration: .init(minLevelShown: .disabled),
            configurationsByTracer: [:]
        )
        try checkLog(memoir: memoir, logShouldPresent: false)
    }

    func testFilteringLoggerOnInfo() throws {
        let memoir = FilteringMemoir(
            memoir: PrintMemoir(),
            defaultConfiguration: .init(minLevelShown: .info),
            configurationsByTracer: [:]
        )
        try checkLog(memoir: memoir, logShouldPresent: true)
    }

    func testFilteringLoggerOffInfo()throws {
        let memoir = FilteringMemoir(
            memoir: PrintMemoir(),
            defaultConfiguration: .init(minLevelShown: .warning),
            configurationsByTracer: [:]
        )
        try checkLog(memoir: memoir, logShouldPresent: false)
    }

    func testMultiplexingLogger() throws {
        let memoir = MultiplexingMemoir(memoirs: [ PrintMemoir(), PrintMemoir() ])
        let probe = simpleProbe(memoir: memoir)
        for _ in 0 ..< 2 { // 2 same logs
            let log = try expectLog(probe: probe)
            if !log.contains(probe.label) { throw Problem.noLabelInLog(memoir) }
            if !log.contains(probe.censoredMessage) { throw Problem.noMessageInLog(memoir) }
        }
    }

    private func checkLog(
        memoir: Memoir,
        logShouldPresent: Bool,
        _ updateProbe: (inout LogProbe) -> Void = { _ in },
        file: String = #fileID,
        line: UInt = #line
    ) throws {
        var probe = simpleProbe(memoir: memoir)
        updateProbe(&probe)
        if logShouldPresent {
            try self.logShouldPresent(probe: probe, memoir: memoir, file: file, line: line)
        } else {
            try expectNoLog(probe: probe, file: file, line: line)
        }
    }

    private func logShouldPresent(probe: LogProbe, memoir: Memoir, file: String = #fileID, line: UInt = #line) throws {
        let log = try expectLog(probe: probe)
        if !log.contains(probe.label) {
            fputs("\nProblem at \(file):\(line)\n", stderr)
            throw Problem.noLabelInLog(memoir)
        }
        if !log.contains(probe.censoredMessage) {
            fputs("\nProblem at \(file):\(line)\n", stderr)
            throw Problem.noMessageInLog(memoir)
        }
        if !log.contains(probe.level.testValue) {
            fputs("\nProblem at \(file):\(line)\n", stderr)
            throw Problem.wrongLevelInLog(memoir)
        }
    }
}
// swiftlint:enable line_length
