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
        let context = codePosition(file: file, line: line, function: function)
        let time = formatter.string(from: date)
        let description = Output.logString(time, level, message, label, scopes, meta, context, false)
        print(description)

        Output.logInterceptor?(self, description)
    }

    @inlinable
    public func updateScope(_ scope: Scope, file: String, function: String, line: UInt) {
        info("\(Output.scopeString(scope, false))", label: "", scopes: [], file: file, function: function, line: line)
    }

    @inlinable
    public func endScope(name: String, file: String, function: String, line: UInt) {
        info("\(Output.scopeEndString(name, false))", label: "", scopes: [], file: file, function: function, line: line)
    }

    @usableFromInline
    func codePosition(file: String, line: UInt, function: String) -> String {
        Output.codePosition(file, shortSource ? "" : function, line)
    }
}
