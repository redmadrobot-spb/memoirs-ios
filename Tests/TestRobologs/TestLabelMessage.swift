//
// TestLabelMessage
// sdk-apple
//
// Created by Alex Babaev on 05 May 2021.
//

import XCTest
@testable import Robologs

class TestLabelMessage: GenericTestCase {
    private let basicLoggersWithoutCensoring: [Logger] = [
        PrintLogger(),
        NSLogLogger(isSensitive: false),
        OSLogLogger(subsystem: "Test", isSensitive: false),
    ]

    func testLabelAndMessageInLoggers() {
        failIfThrows("Label, message in log") {
            for logger: Logger in basicLoggersWithoutCensoring {
                let probe = simpleProbe(logger: logger)
                let log = try expectLog(probe: probe)
                if !log.contains(probe.label) { throw Problem.noLabelInLog(logger) }
                if !log.contains(probe.censoredMessage) { throw Problem.noMessageInLog(logger) }
            }
        }
    }

    func testFilteringLoggerOnAll() {
        failIfThrows("Filtering/on all") {
            let logger = FilteringLogger(logger: PrintLogger(), loggingLevelForLabels: [:], defaultLevel: .all)
            try test(logger: logger, logShouldPresent: true)
        }
    }

    func testFilteringLoggerOffAll() {
        failIfThrows("Filtering/off all") {
            let logger = FilteringLogger(logger: PrintLogger(), loggingLevelForLabels: [:], defaultLevel: .disabled)
            try test(logger: logger, logShouldPresent: false)
        }
    }

    func testFilteringLoggerOnInfo() {
        failIfThrows("Filtering/on 'info'") {
            let logger = FilteringLogger(logger: PrintLogger(), loggingLevelForLabels: [:], defaultLevel: .info)
            try test(logger: logger, logShouldPresent: true)
        }
    }

    func testFilteringLoggerOffInfo() {
        failIfThrows("Filtering/off 'info' (on 'warning')") {
            let logger = FilteringLogger(logger: PrintLogger(), loggingLevelForLabels: [:], defaultLevel: .warning)
            try test(logger: logger, logShouldPresent: false)
        }
    }

    private let label: String = "label"
    private let level: Level = .info

    private func simpleProbe(logger: Logger) -> LogProbeAndResult {
        LogProbeAndResult(
            logger: logger,
            date: Date(),
            level: level,
            label: label,
            scopes: [],
            message: "log message",
            censoredMessage: "log message",
            meta: [:],
            censoredMeta: [:]
        )
    }

    private func test(logger: Logger, logShouldPresent: Bool) throws {
        let probe = simpleProbe(logger: logger)
        if logShouldPresent {
            let log = try expectLog(probe: probe)
            if !log.contains(probe.label) { throw Problem.noLabelInLog(logger) }
            if !log.contains(probe.censoredMessage) { throw Problem.noMessageInLog(logger) }
        } else {
            try expectNoLog(probe: probe)
        }
    }
}
