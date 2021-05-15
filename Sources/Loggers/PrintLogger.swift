//
// PrintLogger
// Robologs
//
// Created by Dmitry Shadrin on 27.11.2019.
// Copyright © 2020 Redmadrobot SPb. All rights reserved.
//

import Foundation

/// Default `(Logger)` implementation which uses `print()` to output logs.
public class PrintLogger: Loggable {
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
        scopes: [Scope] = [],
        meta: @autoclosure () -> [String: LogString]?,
        date: Date = Date(),
        file: String = #file, function: String = #function, line: UInt = #line
    ) {
        let context: String
        if shortSource {
            context = Output.codePosition(file, "", line)
        } else {
            context = Output.codePosition(file, function, line)
        }
        let time = formatter.string(from: date)
        let description = Output.logString(time, level, message, label, scopes, meta, context, false)
        print(description)

        Output.logInterceptor?(self, description)
    }

    public func begin(scopes: [Scope]) {
        scopes.forEach { scope in
            print(Output.scopeBeginString(scope, false))
        }
    }

    public func end(scopes: [Scope]) {
        scopes.forEach { scope in
            print(Output.scopeEndString(scope, false))
        }
    }
}
