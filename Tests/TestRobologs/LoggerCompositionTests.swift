//
// LoggerCompositionTests
// sdk-apple
//
// Created by Alex Babaev on 10 May 2021.
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
}
