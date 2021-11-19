//
// TestGenericOutput
// Memoirs
//
// Created by Alex Babaev on 03 May 2021.
// Copyright © 2021 Redmadrobot SPb. All rights reserved.
// Copyright © 2021 Alex Babaev. All rights reserved.
// License: MIT License, https://github.com/redmadrobot-spb/memoirs-ios/blob/main/LICENSE
//

import Foundation
import XCTest
@testable import Memoirs

extension LogLevel {
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
        case noLogFromMemoir(Memoir)
        case unexpectedLogFromMemoir(Memoir)
        case noLevelInLog(Memoir)
        case noLabelInLog(Memoir)
        case noMessageInLog(Memoir)
        case wrongLevelInLog(Memoir)
        case wrongLabelInLog(Memoir)
        case wrongScopeInLog(Memoir)

        var debugDescription: String {
            switch self {
                case .noLogFromMemoir(let memoir):
                    return "No log found, but has to be (memoir: \(memoir))"
                case .unexpectedLogFromMemoir(let memoir):
                    return "Log found, but not expected (memoir: \(memoir))"
                case .noLevelInLog(let memoir):
                    return "No level in log (memoir: \(memoir))"
                case .noLabelInLog(let memoir):
                    return "No label in log (memoir: \(memoir))"
                case .noMessageInLog(let memoir):
                    return "No message in log (memoir: \(memoir))"
                case .wrongLevelInLog(let memoir):
                    return "Wrong level in log (memoir: \(memoir))"
                case .wrongLabelInLog(let memoir):
                    return "Wrong label in log (memoir: \(memoir))"
                case .wrongScopeInLog(let memoir):
                    return "Wrong scope in log (memoir: \(memoir))"
            }
        }
    }

    struct LogProbe {
        let memoir: Memoir

        var date: Date
        var level: LogLevel
        var tracers: [Tracer]

        var message: SafeString
        var censoredMessage: String
        var meta: [String: SafeString]
        var censoredMeta: [String: String]

        var label: String { tracers.first?.string ?? "NO_LABEL_FOUND:(" }
    }

    private var logResults: [(memoir: Memoir, result: String)] = []

    override func setUp() {
        super.setUp()

        Output.logInterceptor = { memoir, item, log in
            switch item {
                case .log:
                    self.logResults.append((memoir: memoir, result: log))
                case .event:
                    break
                case .tracer:
                    break
                case .measurement:
                    break
            }
        }
    }

    func expectLog(probe: LogProbe) throws -> String {
        probe.memoir.log(
            level: probe.level,
            probe.message,
            meta: probe.meta,
            tracers: probe.tracers
        )
        if let result = logResult() {
            return result
        } else {
            throw Problem.noLogFromMemoir(probe.memoir)
        }
    }

    func expectNoLog(probe: LogProbe, file: String = #fileID, line: UInt = #line) throws {
        probe.memoir.log(level: probe.level, probe.message, meta: probe.meta, tracers: probe.tracers)
        let result = logResult()
        if result != nil {
            fputs("\nProblem at \(file):\(line)\n", stderr)
            throw Problem.unexpectedLogFromMemoir(probe.memoir)
        }
    }

    func logResult() -> String? {
        guard !logResults.isEmpty else { return nil }

        return logResults.remove(at: 0).result
    }

    let defaultLevel: LogLevel = .info

    func simpleProbe(memoir: Memoir) -> LogProbe {
        let randomOne = Int.random(in: Int.min ... Int.max)
        let randomTwo = Int.random(in: Int.min ... Int.max)
        return LogProbe(
            memoir: memoir,
            date: Date(),
            level: defaultLevel,
            tracers: [ .label("label \(randomOne)") ],
            message: "log message \(randomTwo)",
            censoredMessage: "log message \(randomTwo)",
            meta: [:],
            censoredMeta: [:]
        )
    }
}
