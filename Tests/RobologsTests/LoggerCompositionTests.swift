//
// LoggerCompositionTests
// Robologs
//
// Created by Alex Babaev on 10 May 2021.
// Copyright © 2021 Redmadrobot SPb. All rights reserved.
//

import XCTest
@testable import Robologs

class LoggerCompositionTests: GenericTestCase {
    let printLogger = PrintLogger()

    func testLoggerLabel() throws {
        let logger = Logger(label: "[Logger]", logger: printLogger)

        logger.debug("Test log 1", label: "[LogLabel]", scopes: [])
        guard let result1 = logResult() else { throw Problem.noLogFromLogger(logger) }

        if !result1.contains("[Logger]") || !(result1.contains("Test log 1")) {
            throw Problem.wrongLabelInLog(logger)
        }

        logger.debug("Test log 2")
        guard let result2 = logResult() else { throw Problem.noLogFromLogger(logger) }

        if !result2.contains("[Logger]") || !(result2.contains("Test log 2")) {
            throw Problem.wrongLabelInLog(logger)
        }
    }

    func testLoggerInLoggerLabel() throws {
        let innerLogger = Logger(label: "[Inner]", logger: printLogger)
        let logger = Logger(label: "[Outer]", logger: innerLogger)

        logger.debug("Test log")
        guard let result = logResult() else { throw Problem.noLogFromLogger(logger) }

        if result.contains("[Outer]") {
            throw Problem.wrongLabelInLog(logger)
        }
    }

    func testScopedScopedLogger() throws {
        let scope1 = Scope(name: "Scope 1")
        let scope2 = Scope(name: "Scope 2")

        let printLogger = PrintLogger()

        let scopedLogger1 = ScopedLogger(scopes: [ scope1 ], logger: printLogger)
        let scopedLogger2 = ScopedLogger(scopes: [ scope2 ], logger: scopedLogger1)

        scopedLogger2.debug("Test log", label: "Label")
        guard let result = logResult() else { throw Problem.noLogFromLogger(scopedLogger2) }

        if !result.contains("{Scope 1}") || !result.contains("{Scope 2}") {
            throw Problem.wrongScopeInLog(scopedLogger2)
        }
    }

    func testLoggerScopedLogger() throws {
        let scope1 = Scope(name: "Scope 1")
        let scope2 = Scope(name: "Scope 2")

        let printLogger = PrintLogger()

        let scopedLogger1 = ScopedLogger(scopes: [ scope1 ], logger: printLogger)
        let logger2 = Logger(scopes: [ scope2 ], logger: scopedLogger1)

        logger2.debug("Test log")
        guard let result = logResult() else { throw Problem.noLogFromLogger(logger2) }

        if !result.contains("{Scope 1}") || !result.contains("{Scope 2}") {
            throw Problem.wrongScopeInLog(logger2)
        }
    }
}
