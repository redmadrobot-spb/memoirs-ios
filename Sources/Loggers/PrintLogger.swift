//
// PrintLogger
// Robologs
//
// Created by Dmitry Shadrin on 27.11.2019.
// Copyright © 2020 Redmadrobot SPb. All rights reserved.
//

import Foundation

/// Default `(Logger)` implementation which uses `print()` to output logs.
public class PrintLogger: Logger {
    @usableFromInline
    let shortSource: Bool
    @usableFromInline
    let formatter: DateFormatter

    /// Creates a new instance of `PrintLogger`.
    public init(onlyTime: Bool = false, shortSource: Bool = false) {
        self.shortSource = shortSource
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
        let context: String
        if shortSource {
            context = collectContext(file: file, function: "", line: line)
        } else {
            context = collectContext(file: file, function: function, line: line)
        }
        let time = formatter.string(from: Date())
        let description = concatenateData(
            time: time, level: level, message: message, label: label, meta: meta, context: context, isSensitive: false
        )
        print(description)
    }
}
