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
        let descriptionParts: [Any?] = [priority, "\(file):\(function):\(line)", label, message(), meta()]
        let description = descriptionParts.compactMap { $0.map(String.init(describing:)) }.joined(separator: " | ")
        NSLog("%@", description)
    }
}
