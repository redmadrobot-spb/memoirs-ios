//
//  NSLogLogger.swift
//  Robologs
//
//  Created by Dmitry Shadrin on 05.12.2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import Foundation

/// Logger which encapsulate NSLog logging system.
public struct NSLogLogger: Logger {
    /// Creates a new instance of `NSLogLogger`.
    public init() {}

    @inlinable
    public func log(
        level: Level,
        message: () -> LogString,
        label: String,
        meta: () -> [String: LogString]?,
        file: String, function: String, line: UInt
    ) {
        let context = collectContext(file: file, function: function, line: line)
        let description = concatenateData(time: "", level: level, message: message, label: label, meta: meta, context: context)
        NSLog("%@", description)
    }
}
