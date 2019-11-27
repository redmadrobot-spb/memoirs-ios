//
//  DefaultPrintLogger.swift
//  Robologs
//
//  Created by Dmitry Shadrin on 27.11.2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

/// Default `(Logger)` - implementation which just `print()` log event in LLDB-console in pretty format.
public struct DefaultPrintLogger: Logger {
    private var timestamp: String {
        Date().description
    }

    public init() { }

    public func log(
        priority: LogPriority,
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line,
        label: @autoclosure () -> String? = nil,
        message: @autoclosure () -> String,
        meta: @autoclosure () -> [String: Any]? = nil
    ) {
        let descriptionArray: [CustomStringConvertible?] = [
            timestamp,
            prettyString(from: priority),
            "\(file):\(function):\(line)",
            label(),
            message(),
            meta()
        ]
        let logString = descriptionArray
            .compactMap { $0?.description }
            .joined(separator: " | ")
        print(logString)
    }

    private func prettyString(from priority: LogPriority) -> String {
        switch priority {
            case .verbose: return "🔍 INFO"
            case .debug: return "⚙️ DEBUG"
            case .info: return "ℹ️ INFO"
            case .warning: return "⚠️ WARNING"
            case .error: return "🔥 ERROR"
            case .assert: return "❕ASSERT"
        }
    }
}
