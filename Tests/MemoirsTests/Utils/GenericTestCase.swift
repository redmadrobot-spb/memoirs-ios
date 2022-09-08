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

        var level: LogLevel
        var tracers: [Tracer]

        var message: SafeString
        var censoredMessage: String

        var label: String { tracers.first?.string ?? "NO_LABEL_FOUND:(" }
    }

    public let markers: Output.Markers = .init()
    private var logResults: [String] = []

    func addIntercepted(log: String) {
        guard !log.contains(markers.tracer) else { return }

        logResults.append(log)
    }

    func expectLog(probe: LogProbe) async throws -> String {
        probe.memoir.log(
            level: probe.level,
            probe.message,
            tracers: probe.tracers
        )
        if let result = try await logResult() {
            return result
        } else {
            throw Problem.noLogFromMemoir(probe.memoir)
        }
    }

    func expectNoLog(probe: LogProbe, file: String = #fileID, line: UInt = #line) async throws {
        probe.memoir.log(level: probe.level, probe.message, tracers: probe.tracers)
        let result = try await logResult()
        if result != nil {
            fputs("\nProblem at \(file):\(line)\n", stderr)
            throw Problem.unexpectedLogFromMemoir(probe.memoir)
        }
    }

    func logResult() async throws -> String? {
//        try await Task.sleep(nanoseconds: 1_000_000_000 / 1000)
        guard !logResults.isEmpty else { return nil }

        return logResults.remove(at: 0)
    }

    let defaultLevel: LogLevel = .info

    func simpleProbe(memoir: Memoir) -> LogProbe {
        let randomOne = Int.random(in: Int.min ... Int.max)
        let randomTwo = Int.random(in: Int.min ... Int.max)
        return LogProbe(
            memoir: memoir,
            level: defaultLevel,
            tracers: [ .label("label \(randomOne)") ],
            message: "log message \(randomTwo)",
            censoredMessage: "log message \(randomTwo)"
        )
    }
}
