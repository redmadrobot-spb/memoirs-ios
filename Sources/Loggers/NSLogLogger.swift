//
//  NSLogLogger.swift
//  Robologs
//
//  Created by Dmitry Shadrin on 05.12.2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import Foundation

/// Logger which encapsulate NSLog logging system.
public class NSLogLogger: Logger {
    public let isSensitive: Bool

    public init(isSensitive: Bool) {
        self.isSensitive = isSensitive
    }

    @inlinable
    public func log(
        level: Level,
        _ message: @autoclosure () -> LogString,
        label: String,
        meta: @autoclosure () -> [String: LogString]? = nil,
        file: String = #file, function: String = #function, line: UInt = #line
    ) {
        let context = collectContext(file: file, function: function, line: line)
        let description = concatenateData(
            time: "", level: level, message: message, label: label, meta: meta, context: context, isSensitive: isSensitive
        )
        NSLog("%@", description)
    }
}
