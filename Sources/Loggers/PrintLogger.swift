//
//  PrintLogger.swift
//  Robologs
//
//  Created by Dmitry Shadrin on 27.11.2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import Foundation

/// Default `(Logger)` - implementation which just `print()` log event in LLDB-console in pretty format.
public struct PrintLogger: Logger {
    /// Current timestamp.
    private var timestamp: Date { Date() }

    /// Creates a `(Logger)` - implementation object.
    public init() { }

    public func log(
        priority: Priority,
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line,
        label: String,
        message: () -> String,
        meta: () -> [String: Any]?
    ) {
        let description = prepareMessage(timestamp, priority, "\(file):\(function):\(line)", label, message(), meta())
        print(description)
    }
}
