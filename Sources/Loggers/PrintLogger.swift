//
//  PrintLogger.swift
//  Robologs
//
//  Created by Dmitry Shadrin on 27.11.2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import Foundation

/// Default `(Logger)` - implementation which just `print()` log event in LLDB-console in pretty format.
@available(iOS 10.0, *)
public struct PrintLogger: Logger {
    private let formatter = ISO8601DateFormatter()
    private var timestamp: String { formatter.string(from: Date()) }

    /// Creates a new instance of `PrintLogger`.
    public init() {}

    public func log(
        level: Level,
        label: String,
        message: () -> String,
        meta: () -> [String: String]?,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        let context = [ file, function, (line == 0 ? "" : "\(line)") ].filter { !$0.isEmpty }.joined(separator: ":")
        let description = [ "\(timestamp)", "\(level)", context, "\(label)", message(), meta().map { "\($0)" } ]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
            .joined(separator: " ")
        print(description)
    }
}
