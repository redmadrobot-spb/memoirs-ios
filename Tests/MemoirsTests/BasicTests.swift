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
    private var basicMemoirsWithoutCensoring: [Memoir] = []

    override func setUp() {
        super.setUp()

        basicMemoirsWithoutCensoring = [
            PrintMemoir(interceptor: { [self] in await resultSaver.append(log: $0) }),
            NSLogMemoir(isSensitive: false, interceptor: { [self] in await resultSaver.append(log: $0) }),
            OSLogMemoir(subsystem: "Test", isSensitive: false, interceptor: { [self] in await resultSaver.append(log: $0) }),
        ]
    }

    private lazy var referenceDate: TimeInterval = 239
    private lazy var referenceDateString: String = {
        PrintMemoir.fullDateFormatter.string(from: Date(timeIntervalSinceReferenceDate: referenceDate))
    }()

    public func testAllLogOverloads() async throws {
        let memoir: Memoir = PrintMemoir(time: .formatter(PrintMemoir.fullDateFormatter), interceptor: { [self] in await resultSaver.append(log: $0) })
        let tracer: Tracer = .label("TestTracer")

        memoir.log(level: .info, "Test log 1", meta: [ "Test Key": "Test Value" ], tracers: [ tracer ], timeIntervalSinceReferenceDate: referenceDate, file: "file", function: "function", line: 239)
        let result = try await logResult()
        guard let result = result, result.contains(referenceDateString), result.contains("TestTracer"), result.contains("Test Key: Test Value"), result.contains("Test log 1") else {
            return XCTFail("Can't call log(level:_:label:scopes:meta:date:file:function:line:)")
        }

        memoir.log(level: .info, "Test log 2", meta: [ "Test Key": "Test Value" ], tracers: [ tracer ], timeIntervalSinceReferenceDate: referenceDate, file: "file", function: "function")
        guard let result = try await logResult(), result.contains(referenceDateString), result.contains("TestTracer"), result.contains("Test Key: Test Value"), result.contains("Test log 2") else { // TODO: Check date and meta
            return XCTFail("Can't call log(level:_:label:scopes:meta:date:file:function:)")
        }

        memoir.log(level: .info, "Test log 3", meta: [ "Test Key": "Test Value" ], tracers: [ tracer ], timeIntervalSinceReferenceDate: referenceDate, file: "file")
        guard let result = try await logResult(), result.contains(referenceDateString), result.contains("TestTracer"), result.contains("Test Key: Test Value"), result.contains("Test log 3") else { // TODO: Check date and meta
            return XCTFail("Can't call log(level:_:label:scopes:meta:date:file:)")
        }

        memoir.log(level: .info, "Test log 4", meta: [ "Test Key": "Test Value" ], tracers: [ tracer ], timeIntervalSinceReferenceDate: referenceDate)
        guard let result = try await logResult(), result.contains(referenceDateString), result.contains("TestTracer"), result.contains("Test Key: Test Value"), result.contains("Test log 4") else { // TODO: Check date and meta
            return XCTFail("Can't call log(level:_:label:scopes:meta:date:)")
        }

        memoir.log(level: .info, "Test log 5", meta: [ "Test Key": "Test Value" ], tracers: [ tracer ])
        guard let result = try await logResult(), result.contains("TestTracer"), result.contains("Test Key: Test Value"), result.contains("Test log 5") else { // TODO: Check date and meta
            return XCTFail("Can't call log(level:_:label:scopes:meta:)")
        }

        memoir.log(level: .info, "Test log 6", tracers: [ tracer ])
        guard let result = try await logResult(), result.contains("TestTracer"), result.contains("Test log 6") else { // TODO: Check date and meta
            return XCTFail("Can't call log(level:_:label:scopes:meta:)")
        }
    }

    lazy var levelMarkers: [LogLevel: String] = [
        .verbose: markers.verbose,
        .debug: markers.debug,
        .info: markers.info,
        .warning: markers.warning,
        .error: markers.error,
        .critical: markers.critical,
    ]

    func testConfigureOutput() async throws {
        let memoir = PrintMemoir(interceptor: { [self] in await resultSaver.append(log: $0) })
        for (level, string) in levelMarkers {
            var probe = simpleProbe(memoir: memoir)
            probe.level = level
            let log = try await expectLog(probe: probe)
            if !log.contains(string) {
                throw Problem.noLabelInLog(memoir, string)
            }
        }
    }

    func testLabelAndMessageInLoggers() async throws {
        for memoir: Memoir in basicMemoirsWithoutCensoring {
            let probe = simpleProbe(memoir: memoir)
            let log = try await expectLog(probe: probe)
            if !log.contains(probe.label) { throw Problem.noLabelInLog(memoir, probe.label) }
            if !log.contains(probe.censoredMessage) { throw Problem.noMessageInLog(memoir, probe.censoredMessage) }
        }
    }

    func testTracedMemoir() async throws {
        let allLevels: [LogLevel] = [ .verbose, .debug, .info, .warning, .error, .critical ]
        let printMemoir = PrintMemoir(shortTracers: true, interceptor: { [self] in await resultSaver.append(log: $0) })
        let memoir = TracedMemoir(label: "label_\(Int.random(in: Int.min ... Int.max))", memoir: printMemoir)
        for level in allLevels {
            var probe = simpleProbe(memoir: memoir)
            probe.level = level
            try await logShouldPresent(probe: probe)
        }
    }

    func testLabeledScopedLogger() async throws {
        let allLevels: [LogLevel] = [ .verbose, .debug, .info, .warning, .error, .critical ]
        let printMemoir = PrintMemoir(tracerFilter: { _ in false }, interceptor: { [self] in await resultSaver.append(log: $0) })
        let tracer: Tracer = .label("tracer_\(Int.random(in: Int.min ... Int.max))")
        let memoir = TracedMemoir(
            label: "label_\(Int.random(in: Int.min ... Int.max))",
            memoir: TracedMemoir(tracer: tracer, meta: [:], memoir: printMemoir)
        )
        for level in allLevels {
            var probe = simpleProbe(memoir: memoir)
            probe.tracers = [ tracer ]
            probe.level = level
            try await logShouldPresent(probe: probe)
        }
    }

    func testFilteringLevels() async throws {
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
                memoir: PrintMemoir(interceptor: { [self] in await resultSaver.append(log: $0) }),
                defaultConfiguration: .init(minLevelShown: configurationLevel),
                configurationsByTracer: [:]
            )
            for (level, levelIndex) in allLevels {
                try await checkLog(memoir: memoir, logShouldPresent: levelIndex >= configurationIndex) { $0.level = level }
            }
        }
    }

    func testFilteringLoggerOnAll() async throws {
        let memoir = FilteringMemoir(
            memoir: PrintMemoir(interceptor: { [self] in await resultSaver.append(log: $0) }),
            defaultConfiguration: .init(minLevelShown: .all),
            configurationsByTracer: [:]
        )
        try await checkLog(memoir: memoir, logShouldPresent: true)
    }

    func testFilteringLoggerOffAll() async throws {
        let memoir = FilteringMemoir(
            memoir: PrintMemoir(interceptor: { [self] in await resultSaver.append(log: $0) }),
            defaultConfiguration: .init(minLevelShown: .disabled),
            configurationsByTracer: [:]
        )
        try await checkLog(memoir: memoir, logShouldPresent: false)
    }

    func testFilteringLoggerOnInfo() async throws {
        let memoir = FilteringMemoir(
            memoir: PrintMemoir(interceptor: { [self] in await resultSaver.append(log: $0) }),
            defaultConfiguration: .init(minLevelShown: .info),
            configurationsByTracer: [:]
        )
        try await checkLog(memoir: memoir, logShouldPresent: true)
    }

    func testFilteringLoggerOffInfo() async throws {
        let memoir = FilteringMemoir(
            memoir: PrintMemoir(interceptor: { [self] in await resultSaver.append(log: $0) }),
            defaultConfiguration: .init(minLevelShown: .warning),
            configurationsByTracer: [:]
        )
        try await checkLog(memoir: memoir, logShouldPresent: false)
    }

    func testMultiplexingLogger() async throws {
        let memoir = MultiplexingMemoir(memoirs: [ PrintMemoir(interceptor: { [self] in await resultSaver.append(log: $0) }), PrintMemoir(interceptor: { [self] in await resultSaver.append(log: $0) }) ])
        let probe = simpleProbe(memoir: memoir)
        for _ in 0 ..< 2 { // 2 same logs
            let log = try await expectLog(probe: probe)
            if !log.contains(probe.label) { throw Problem.noLabelInLog(memoir, probe.label) }
            if !log.contains(probe.censoredMessage) { throw Problem.noMessageInLog(memoir, probe.censoredMessage) }
        }
    }

    private func checkLog(
        memoir: Memoir,
        logShouldPresent: Bool,
        _ updateProbe: (inout LogProbe) -> Void = { _ in },
        file: String = #fileID,
        line: UInt = #line
    ) async throws {
        var probe = simpleProbe(memoir: memoir)
        updateProbe(&probe)
        if logShouldPresent {
            try await self.logShouldPresent(probe: probe, file: file, line: line)
        } else {
            try await expectNoLog(probe: probe, file: file, line: line)
        }
    }

    private func logShouldPresent(probe: LogProbe, file: String = #fileID, line: UInt = #line) async throws {
        try await Task.sleep(for: .seconds(0.01))
        let log = try await expectLog(probe: probe)
        if !log.contains(probe.label) {
            fputs("\nProblem at \(file):\(line)\n", stderr)
            throw Problem.noLabelInLog(probe.memoir, probe.label)
        }
        if !log.contains(probe.censoredMessage) {
            fputs("\nProblem at \(file):\(line)\n", stderr)
            throw Problem.noMessageInLog(probe.memoir, probe.censoredMessage)
        }
        if !log.contains(levelMarkers[probe.level] ?? "NOT_A_MARKER") {
            fputs("\nProblem at \(file):\(line)\n", stderr)
            throw Problem.wrongLevelInLog(probe.memoir)
        }
    }
}
// swiftlint:enable line_length
