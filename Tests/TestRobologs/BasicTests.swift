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
    private let basicLoggersWithoutCensoring: [Logger] = [
        PrintLogger(),
        NSLogLogger(isSensitive: false),
        OSLogLogger(subsystem: "Test", isSensitive: false),
    ]

    func testLabelAndMessageInLoggers() throws {
        for logger: Logger in basicLoggersWithoutCensoring {
            let probe = simpleProbe(logger: logger)
            let log = try expectLog(probe: probe)
            if !log.contains(probe.label) { throw Problem.noLabelInLog(logger) }
            if !log.contains(probe.censoredMessage) { throw Problem.noMessageInLog(logger) }
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
                try test(logger: logger, logShouldPresent: levelIndex >= configurationIndex) { $0.level = level }
            }
        }
    }

    func testFilteringLoggerOnAll() throws {
        let logger = FilteringLogger(logger: PrintLogger(), loggingLevelForLabels: [:], defaultLevel: .all)
        try test(logger: logger, logShouldPresent: true)
    }

    func testFilteringLoggerOffAll() throws {
        let logger = FilteringLogger(logger: PrintLogger(), loggingLevelForLabels: [:], defaultLevel: .disabled)
        try test(logger: logger, logShouldPresent: false)
    }

    func testFilteringLoggerOnInfo() throws {
        let logger = FilteringLogger(logger: PrintLogger(), loggingLevelForLabels: [:], defaultLevel: .info)
        try test(logger: logger, logShouldPresent: true)
    }

    func testFilteringLoggerOffInfo()throws {
        let logger = FilteringLogger(logger: PrintLogger(), loggingLevelForLabels: [:], defaultLevel: .warning)
        try test(logger: logger, logShouldPresent: false)
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

    private let level: Level = .info

    private func simpleProbe(logger: Logger) -> LogProbe {
        let randomOne = Int.random(in: Int.min ... Int.max)
        let randomTwo = Int.random(in: Int.min ... Int.max)
        return LogProbe(
            logger: logger,
            date: Date(),
            level: level,
            label: "label \(randomOne)",
            scopes: [],
            message: "log message \(randomTwo)",
            censoredMessage: "log message \(randomTwo)",
            meta: [:],
            censoredMeta: [:]
        )
    }

    private func test(
        logger: Logger,
        logShouldPresent: Bool,
        _ updateProbe: (inout LogProbe) -> Void = { _ in },
        file: String = #file,
        line: UInt = #line
    ) throws {
        var probe = simpleProbe(logger: logger)
        updateProbe(&probe)
        if logShouldPresent {
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
        } else {
            try expectNoLog(probe: probe, file: file, line: line)
        }
    }
}
