//
// NullLogger
// Robologs
//
// Created by Alex Babaev on 27 April 2020.
// Copyright (c) 2020 Redmadrobot. All rights reserved.
//

import Foundation

public class NullLogger: Logger {
    public init() {
    }

    @inlinable
    public func log(
        level: Level,
        _ message: @autoclosure () -> LogString,
        label: String,
        meta: @autoclosure () -> [String: LogString]? = nil,
        file: String = #file, function: String = #function, line: UInt = #line
    ) {
    }
}
