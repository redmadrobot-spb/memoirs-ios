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
    public func add(
        _ item: Log.Item,
        meta: @autoclosure () -> [String: Log.String]?,
        tracers: [Log.Tracer],
        date: Date,
        file: String, function: String, line: UInt
    ) {
    }
}
