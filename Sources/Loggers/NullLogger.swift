//
// NullLogger
// Robologs
//
// Created by Alex Babaev on 27 April 2020.
// Copyright © 2020 Redmadrobot SPb. All rights reserved.
//

import Foundation

public class NullLogger: Loggable {
    public init() {
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
    }

    public func begin(scopes: [Scope]) {
    }

    public func end(scopes: [Scope]) {
    }
}