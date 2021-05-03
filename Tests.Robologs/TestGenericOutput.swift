//
// TestGenericOutput
// sdk-apple
//
// Created by Alex Babaev on 03 May 2021.
//

import Foundation
import XCTest
@testable import Robologs

extension Level {
    var code: Int {
        switch self {
            case .verbose: return 1
            case .debug: return 2
            case .info: return 3
            case .warning: return 4
            case .error: return 5
            case .critical: return 6
        }
    }
}

class TestGenericOutput: XCTestCase {
    struct CodeLocation: Encodable {
        let file: String
        let function: String
        let line: UInt
    }

    struct LogString: Encodable {
        let time: String
        let level: Int?
        let message: String
        let label: String
        let scopes: [String]
        let meta: [String: String]?
        let codePosition: String
        let isSensitive: Bool
    }



    override class func setUp() {
        super.setUp()

        let encoder = JSONEncoder()

        Output.codePosition = { file, function, line in
            let data = CodeLocation(file: file, function: function, line: line)
            // swiftlint:disable:next force_try force_unwrapping
            return String(data: try! encoder.encode(data), encoding: .utf8)!
        }
        Output.logString = { time, level, message, label, scopes, meta, codePosition, isSensitive in
            let data = LogString(
                time: time,
                level: level?.code,
                message: message().string(isSensitive: isSensitive),
                label: label,
                scopes: scopes.map { "\($0)" },
                meta: meta()?.mapValues { $0.string(isSensitive: isSensitive) },
                codePosition: codePosition,
                isSensitive: false
            )
            // swiftlint:disable:next force_try force_unwrapping
            return String(data: try! encoder.encode(data), encoding: .utf8)!
        }
    }

    override class func tearDown() {
        Output.codePosition = Output.defaultCodePosition
        Output.logString = Output.defaultLogString
    }

    func test() {
        let logger = PrintLogger()
        logger.log(level: .critical, "log", label: "label", scopes: [], meta: [:], file: "file", function: "function", line: 239)
    }
}
