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
        priority: Priority,
        label: String,
        message: () -> String,
        meta: () -> [String: String]?,
        file: StaticString,
        function: StaticString,
        line: UInt
    ) {
        var metaDescription = ""
        if let meta = meta() {
            metaDescription = " | \(meta)"
        }
        NSLog("%@%@", "\(priority) | \(file):\(function):\(line) | \(label) | \(message())", metaDescription)
    }
}
