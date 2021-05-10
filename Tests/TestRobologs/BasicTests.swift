//
// BasicTests
// Robologs
//
// Created by Alex Babaev on 05 May 2021.
// Copyright © 2021 Redmadrobot SPb. All rights reserved.
//

import XCTest
@testable import Robologs

class BasicTests: GenericTestCase {
    private let basicLoggersWithoutCensoring: [Loggable] = [
        PrintLogger(),
        NSLogLogger(isSensitive: false),
        OSLogLogger(subsystem: "Test", isSensitive: false),
    ]

    func testConfigureOutput() throws {
        let levelStrings: [Level: String] = [
            .verbose: "[VVV]",
            .debug: "[DDD]",
            .info: "[III]",
            .warning: "[WWW]",
            .error: "[EEE]",
            .critical: "[CCC]",
        ]
        Output.logString = Output.defaultLogString
        Level.configure(
            stringForVerbose: levelStrings[.verbose]!,
            stringForDebug: levelStrings[.debug]!,
            stringForInfo: levelStrings[.info]!,
            stringForWarning: levelStrings[.warning]!,
            stringForError: levelStrings[.error]!,
            stringForCritical: levelStrings[.critical]!
        )

        let logger = PrintLogger()
        for (level, string) in levelStrings {
            var probe = simpleProbe(logger: logger)
            probe.level = level
            let log = try expectLog(probe: probe)
            if !log.contains(string) {
                throw Problem.noLabelInLog(logger)
            }
        }
    }

    func testLabelAndMessageInLoggers() throws {
        for logger: Loggable in basicLoggersWithoutCensoring {
            let probe = simpleProbe(logger: logger)
            let log = try expectLog(probe: probe)
            if !log.contains(probe.label) { throw Problem.noLabelInLog(logger) }
            if !log.contains(probe.censoredMessage) { throw Problem.noMessageInLog(logger) }
        }
    }

    func testLabeledLogger() throws {
        let allLevels: [Level] = [ .verbose, .debug, .info, .warning, .error, .critical ]
        let printLogger = PrintLogger()
        let label = "label_\(Int.random(in: Int.min ... Int.max))"
        let logger = LabeledLogger(label: label, logger: printLogger)
        for level in allLevels {
            var probe = simpleProbe(logger: logger)
            probe.level = level
            try logShouldPresent(probe: probe, logger: logger)
        }
    }

    func testScopedLogger() throws {
        let allLevels: [Level] = [ .verbose, .debug, .info, .warning, .error, .critical ]
        let printLogger = PrintLogger()
        let scope = Scope(name: "scope_\(Int.random(in: Int.min ... Int.max))")
        let logger = ScopedLogger(scopes: [ scope ], logger: printLogger)
        for level in allLevels {
            var probe = simpleProbe(logger: logger)
            probe.level = level
            try logShouldPresent(probe: probe, logger: logger)
        }
    }

    func testLabeledScopedLogger() throws {
        let allLevels: [Level] = [ .verbose, .debug, .info, .warning, .error, .critical ]
        let printLogger = PrintLogger()
        let label = "label_\(Int.random(in: Int.min ... Int.max))"
        let scope = Scope(name: "scope_\(Int.random(in: Int.min ... Int.max))")
        let logger = Logger(label: label, scopes: [ scope ], logger: printLogger)
        for level in allLevels {
            var probe = simpleProbe(logger: logger)
            probe.level = level
            try logShouldPresent(probe: probe, logger: logger)
        }
    }

    func testFilteringLevels() throws {
        let allConfigurationLevels: [(FilteringLogger.ConfigurationLevel, Int)] =
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
        let allLevels: [(Level, Int)] =
            [
                (.verbose, 0),
                (.debug, 1),
                (.info, 2),
                (.warning, 3),
                (.error, 4),
                (.critical, 5),
            ]
        for (configurationLevel, configurationIndex) in allConfigurationLevels {
            let logger = FilteringLogger(logger: PrintLogger(), loggingLevelForLabels: [:], defaultLevel: configurationLevel)
            for (level, levelIndex) in allLevels {
                try checkLog(logger: logger, logShouldPresent: levelIndex >= configurationIndex) { $0.level = level }
            }
        }
    }

    func testFilteringLoggerOnAll() throws {
        let logger = FilteringLogger(logger: PrintLogger(), loggingLevelForLabels: [:], defaultLevel: .all)
        try checkLog(logger: logger, logShouldPresent: true)
    }

    func testFilteringLoggerOffAll() throws {
        let logger = FilteringLogger(logger: PrintLogger(), loggingLevelForLabels: [:], defaultLevel: .disabled)
        try checkLog(logger: logger, logShouldPresent: false)
    }

    func testFilteringLoggerOnInfo() throws {
        let logger = FilteringLogger(logger: PrintLogger(), loggingLevelForLabels: [:], defaultLevel: .info)
        try checkLog(logger: logger, logShouldPresent: true)
    }

    func testFilteringLoggerOffInfo()throws {
        let logger = FilteringLogger(logger: PrintLogger(), loggingLevelForLabels: [:], defaultLevel: .warning)
        try checkLog(logger: logger, logShouldPresent: false)
    }

    func testMultiplexingLogger() throws {
        let logger = MultiplexingLogger(loggers: [ PrintLogger(), PrintLogger() ])
        let probe = simpleProbe(logger: logger)
        for _ in 0 ..< 2 { // 2 same logs
            let log = try expectLog(probe: probe)
            if !log.contains(probe.label) { throw Problem.noLabelInLog(logger) }
            if !log.contains(probe.censoredMessage) { throw Problem.noMessageInLog(logger) }
        }
    }

    private func checkLog(
        logger: Loggable,
        logShouldPresent: Bool,
        _ updateProbe: (inout LogProbe) -> Void = { _ in },
        file: String = #file,
        line: UInt = #line
    ) throws {
        var probe = simpleProbe(logger: logger)
        updateProbe(&probe)
        if logShouldPresent {
            try self.logShouldPresent(probe: probe, logger: logger, file: file, line: line)
        } else {
            try expectNoLog(probe: probe, file: file, line: line)
        }
    }

    private func logShouldPresent(probe: LogProbe, logger: Loggable, file: String = #file, line: UInt = #line) throws {
        let log = try expectLog(probe: probe)
        if !log.contains(probe.label) {
            fputs("\nProblem at \(file):\(line)\n", stderr)
            throw Problem.noLabelInLog(logger)
        }
        if !log.contains(probe.censoredMessage) {
            fputs("\nProblem at \(file):\(line)\n", stderr)
            throw Problem.noMessageInLog(logger)
        }
        if !log.contains(probe.level.testValue) {
            fputs("\nProblem at \(file):\(line)\n", stderr)
            throw Problem.wrongLevelInLog(logger)
        }
    }
}
