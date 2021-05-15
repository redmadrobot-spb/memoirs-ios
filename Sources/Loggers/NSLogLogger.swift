//
// NSLogLogger
// Robologs
//
// Created by Dmitry Shadrin on 05.12.2019.
// Copyright © 2020 Redmadrobot SPb. All rights reserved.
//

import Foundation

/// Logger which encapsulate NSLog logging system.
public class NSLogLogger: Loggable {
    public let isSensitive: Bool

    public init(isSensitive: Bool) {
        self.isSensitive = isSensitive
    }

    @inlinable
    public func log(
        level: Level,
        _ message: @autoclosure () -> LogString,
        label: String,
        scopes: [Scope] = [],
        meta: @autoclosure () -> [String: LogString]? = nil,
        date: Date = Date(),
        file: String = #file, function: String = #function, line: UInt = #line
    ) {
        let context = Output.codePosition(file, function, line)
        let description = Output.logString("", level, message, label, scopes, meta, context, isSensitive)
        NSLog("%@", description)

        Output.logInterceptor?(self, description)
    }

    @inlinable
    public func update(scope: Scope, file: String = #file, function: String = #function, line: UInt = #line) {
        NSLog("%@", Output.scopeString(scope, isSensitive))
    }
}
