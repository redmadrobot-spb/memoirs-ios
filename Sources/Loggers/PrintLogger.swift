//
//  PrintLogger.swift
//  Robologs
//
//  Created by Dmitry Shadrin on 27.11.2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import Foundation

/// Default `(Logger)` - implementation which just `print()` log event in LLDB-console in pretty format.
public struct PrintLogger: Logger {
    /// Current timestamp.
    private var timestamp: String {
        Date().description
    }

    public init() { }

    public func log(
        priority: Priority,
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line,
        label: () -> String?,
        message: () -> String,
        meta: () -> [String: Any]?
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

    private func prettyString(from priority: Priority) -> String {
        switch priority {
            case .verbose:
                return "🟣 VERBOSE"
            case .debug:
                return "🔵 DEBUG"
            case .info:
                return "🟢 INFO"
            case .warning:
                return "🟡 WARNING"
            case .error:
                return "🟠 ERROR"
            case .critical:
                return "🔴 CRITICAL"
        }
    }
}
