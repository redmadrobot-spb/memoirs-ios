//
// TestGenericOutput
// sdk-apple
//
// Created by Alex Babaev on 03 May 2021.
//

import Foundation
import XCTest
@testable import Robologs

class GenericTestCase: XCTestCase {
    enum Problem: Error {
        case noLogFromLogger(Logger)
        case unexpectedLogFromLogger(Logger)
        case noLabelInLog(Logger)
        case noMessageInLog(Logger)
    }

    struct LogProbeAndResult {
        let logger: Logger

        let date: Date
        let level: Level
        let label: String
        let scopes: [Scope]

        let message: LogString
        let censoredMessage: String
        let meta: [String: LogString]
        let censoredMeta: [String: String]

        var result: String?
    }

    private var lastLogResult: (logger: Logger, result: String)?

    override func setUp() {
        super.setUp()

        Output.logInterceptor = { logger, log in
            self.lastLogResult = (logger: logger, result: log)
        }
    }

    override func tearDown() {
        super.tearDown()

        Output.codePosition = Output.defaultCodePosition
        Output.logString = Output.defaultLogString
    }

    func expectLog(probe: LogProbeAndResult) throws -> String {
        probe.logger.log(
            level: probe.level,
            "\(probe.message)",
            label: probe.label,
            scopes: probe.scopes,
            meta: probe.meta.mapValues { "\($0)" }
        )
        let probe = try updatedResult(in: probe)
        guard let result = probe.result else { throw Problem.noLogFromLogger(probe.logger) }

        return result
    }

    func expectNoLog(probe: LogProbeAndResult) throws {
        probe.logger.log(
            level: probe.level,
            "\(probe.message)",
            label: probe.label,
            scopes: probe.scopes,
            meta: probe.meta.mapValues { "\($0)" }
        )
        let probe = try updatedResult(in: probe)
        if probe.result != nil {
            throw Problem.unexpectedLogFromLogger(probe.logger)
        }
    }

    func failIfThrows(_ description: String? = nil, _ testClosure: () throws -> Void) {
        do {
            try testClosure()
        } catch {
            XCTFail("\(description ?? "Failed"): \(error)")
        }
    }

    private func updatedResult(in probe: LogProbeAndResult) throws -> LogProbeAndResult {
        var probe = probe
        probe.result = lastLogResult?.result
        lastLogResult = nil
        return probe
    }
}
