//
// TestGenericOutput
// Robologs
//
// Created by Alex Babaev on 03 May 2021.
// Copyright © 2021 Redmadrobot SPb. All rights reserved.
//

import Foundation
import XCTest
@testable import Robologs

extension Level {
    var testValue: String {
        switch self {
            case .verbose: return "[{verbose}]"
            case .debug: return "[{debug}]"
            case .info: return "[{info}]"
            case .warning: return "[{warning}]"
            case .error: return "[{error}]"
            case .critical: return "[{critical}]"
        }
    }
}

class GenericTestCase: XCTestCase {
    enum Problem: Error, CustomDebugStringConvertible {
        case noLogFromLogger(Loggable)
        case unexpectedLogFromLogger(Loggable)
        case noLabelInLog(Loggable)
        case noMessageInLog(Loggable)
        case wrongLevelInLog(Loggable)

        var debugDescription: String {
            switch self {
                case .noLogFromLogger(let logger):
                    return "No log found, but has to be (logger: \(logger))"
                case .unexpectedLogFromLogger(let logger):
                    return "Log found, but not expected (logger: \(logger))"
                case .noLabelInLog(let logger):
                    return "No label in log (logger: \(logger))"
                case .noMessageInLog(let logger):
                    return "No message in log (logger: \(logger))"
                case .wrongLevelInLog(let logger):
                    return "Wrong level in log (logger: \(logger))"
            }
        }
    }

    struct LogProbe {
        let logger: Loggable

        var date: Date
        var level: Level
        var label: String
        var scopes: [Scope]

        var message: LogString
        var censoredMessage: String
        var meta: [String: LogString]
        var censoredMeta: [String: String]

        var result: String?
    }

    private var logResults: [(logger: Loggable, result: String)] = []

    override func setUp() {
        super.setUp()

        Output.logString = { _, level, message, label, _, _, _, isSensitive in
            "\(level.testValue) | \(label) | \(message().string(isSensitive: isSensitive))"
        }
        Output.logInterceptor = { logger, log in
            self.logResults.append((logger: logger, result: log))
        }
    }

    override func tearDown() {
        super.tearDown()

        Output.codePosition = Output.defaultCodePosition
        Output.logString = Output.defaultLogString
    }

    func expectLog(probe: LogProbe) throws -> String {
        probe.logger.log(
            level: probe.level,
            probe.message,
            label: probe.label,
            scopes: probe.scopes,
            meta: probe.meta
        )
        if let probe = try updatedResult(in: probe), let result = probe.result {
            return result
        } else {
            throw Problem.noLogFromLogger(probe.logger)
        }
    }

    func expectNoLog(probe: LogProbe, file: String = #file, line: UInt = #line) throws {
        probe.logger.log(
            level: probe.level,
            probe.message,
            label: probe.label,
            scopes: probe.scopes,
            meta: probe.meta
        )
        if let probe = try updatedResult(in: probe), probe.result != nil {
            fputs("\nProblem at \(file):\(line)\n", stderr)
            throw Problem.unexpectedLogFromLogger(probe.logger)
        }
    }

    private func updatedResult(in probe: LogProbe) throws -> LogProbe? {
        guard !logResults.isEmpty else { return nil }

        var probe = probe
        probe.result = logResults.remove(at: 0).result
        return probe
    }
}
