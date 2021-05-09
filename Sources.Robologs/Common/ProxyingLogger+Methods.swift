//
// Logger.Convenience
// Robologs
//
// Created by Alex Babaev on 09.05.2021.
// Copyright © 2021 Redmadrobot SPb. All rights reserved.
//

import Foundation

public extension LoggableProxy {
    @inlinable
    func log(
        level: Level,
        _ message: @autoclosure () -> LogString,
        label: String,
        scopes: [Scope] = [],
        meta: @autoclosure () -> [String: LogString]? = nil,
        date: Date = Date(),
        file: String = #file, function: String = #function, line: UInt = #line
    ) {
        logger.log(
            level: level, message(), label: label, scopes: scopes, meta: meta(), date: date, file: file, function: function, line: line
        )
    }
}
