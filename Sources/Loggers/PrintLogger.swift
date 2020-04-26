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
    public let formatter: DateFormatter

    /// Creates a new instance of `PrintLogger`.
    public init(onlyTime: Bool = false) {
        formatter = DateFormatter()
        formatter.dateFormat = onlyTime ? "HH:mm:ss.SSS" : "yyyy-MM-dd HH:mm:ss.SSSZ"
        formatter.locale = Locale(identifier: "en_US_POSIX")
    }

    @inlinable
    public func log(
        level: Level,
        _ message: @autoclosure () -> LogString,
        label: String,
        meta: @autoclosure () -> [String: LogString]?,
        file: String = #file, function: String = #function, line: UInt = #line
    ) {
        let context = collectContext(file: file, function: function, line: line)
        let time = formatter.string(from: Date())
        let description = concatenateData(time: time, level: level, message: message, label: label, meta: meta, context: context)
        print(description)
    }
}
