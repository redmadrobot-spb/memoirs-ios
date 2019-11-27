//
//  Logger.swift
//  Robologs
//
//  Created by Dmitry Shadrin on 27.11.2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

/// Protocol describing requirements for work with `Robolog` logging system.
public protocol Logger {
    /// A unique key that allows conveniently store each logger
    var key: Int { get }

    func log(
        priority: LogPriority,
        file: StaticString,
        function: StaticString,
        line: UInt,
        label: @autoclosure () -> String?,
        message: @autoclosure () -> String,
        meta: @autoclosure () -> [String: Any]?
    )
}

extension Logger {
    /// The default key that uses the type name
    public var key: Int {
        return String(describing: Self.self).hashValue
    }
}
