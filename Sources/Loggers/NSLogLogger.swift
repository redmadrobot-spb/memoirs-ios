//
//  NSLogLogger.swift
//  Robologs
//
//  Created by Dmitry Shadrin on 05.12.2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import Foundation

/// Logger which incapsulate NSLog logging system.
public struct NSLogLogger: Logger {
    /// Creates a new instance of `NSLogLogger`.
    public init() {}

    public func log(
        level: Level,
        label: String,
        message: () -> LogString,
        meta: () -> [String: LogString]?,
        file: String,
        function: String,
        line: UInt
    ) {
        let context = [ file, function, (line == 0 ? "" : "\(line)") ].filter { !$0.isEmpty }.joined(separator: ":")
        let description = [ "\(level)", context, label, "\(message())", meta().map { $0.isEmpty ? "" : "\($0)" } ]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
            .joined(separator: " ")
        NSLog("%@", description)
    }
}
