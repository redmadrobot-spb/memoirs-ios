//
//  PrintLogger.swift
//  Robologs
//
//  Created by Dmitry Shadrin on 27.11.2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import Foundation

/// Default `(Logger)` implementation which uses `print()` to output logs.
public struct PrintLogger: Logger {
    private let formatter: DateFormatter

    /// Creates a new instance of `PrintLogger`.
    public init(onlyTime: Bool = false) {
        formatter = DateFormatter()
        formatter.dateFormat = onlyTime ? "HH:mm:ss.SSSZ" : "yyyy-MM-dd HH:mm:ss.SSSZ"
        formatter.locale = Locale(identifier: "en_US_POSIX")
    }

    public func log(
        level: Level,
        message: () -> LogString,
        label: String,
        meta: () -> [String: LogString]?,
        file: String,
        function: String,
        line: UInt
    ) {
        let context = collectContext(file: file, function: function, line: line)
        let timestamp = formatter.string(from: Date())
        let description = [ "\(timestamp)", "\(level)", context, "\(label)", "\(message())", meta().map { $0.isEmpty ? "" : "\($0)" } ]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
            .joined(separator: " ")
        print(description)
    }
}
