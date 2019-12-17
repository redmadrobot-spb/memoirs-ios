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
    private var timestamp: Date { Date() }

    /// Creates a new instance of `PrintLogger`.
    public init() { }

    public func log(
        priority: Priority,
        label: String,
        message: () -> String,
        meta: () -> [String: String]?,
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line
    ) {
        let description = [
            "\(timestamp)", "\(priority)", "\(file):\(function):\(line)", "\(label)", message(), meta().map { "\($0)" }
        ]
        .compactMap { $0 }
        .joined(separator: " ")
        print(description)
    }
}
