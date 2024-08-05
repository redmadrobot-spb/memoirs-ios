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

actor ResultSaver {
    private let markers: Output.Markers = .init()
    private(set) var logResults: [String] = []

    func clear() {
        logResults = []
    }

    func append(log: String) {
        logResults.append(log)
    }

    func appendIfNotTracer(log: String) {
        guard !log.contains(markers.tracer) else { return }

        logResults.append(log)
    }

    var pop: String? {
        guard !logResults.isEmpty else { return nil }

        return logResults.remove(at: 0)
    }
}

class GenericTestCase: XCTestCase {
    enum Problem: Error, CustomDebugStringConvertible {
        case noLogFromMemoir(Memoir)
        case unexpectedLogFromMemoir(Memoir)
        case noLevelInLog(Memoir)
        case noLabelInLog(Memoir, String)
        case noMessageInLog(Memoir, String)
        case wrongLevelInLog(Memoir)
        case wrongLabelInLog(Memoir, String)
        case wrongScopeInLog(Memoir)

        var debugDescription: String {
            switch self {
                case .noLogFromMemoir(let memoir):
                    return "No log found, but has to be (memoir: \(memoir))"
                case .unexpectedLogFromMemoir(let memoir):
                    return "Log found, but not expected (memoir: \(memoir))"
                case .noLevelInLog(let memoir):
                    return "No level in log (memoir: \(memoir))"
                case .noLabelInLog(let memoir, let label):
                    return "No label “\(label)” in log (memoir: \(memoir))"
                case .noMessageInLog(let memoir, let message):
                    return "No message “\(message)” in log (memoir: \(memoir))"
                case .wrongLevelInLog(let memoir):
                    return "Wrong level in log (memoir: \(memoir))"
                case .wrongLabelInLog(let memoir, let label):
                    return "Wrong label “\(label)” in log (memoir: \(memoir))"
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
    let resultSaver: ResultSaver = .init()

    func expectLog(probe: LogProbe) async throws -> String {
        await resultSaver.clear()
        probe.memoir.log(level: probe.level, probe.message, tracers: probe.tracers)
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
        try await Task.sleep(for: .seconds(0.01))
        return await resultSaver.pop
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
