//
// TracedLogger
// Robologs
//
// Created by Alex Babaev on 22 May 2021.
// Copyright © 2021 Alex Babaev. All rights reserved.
//

import Foundation

public class TracedLogger: Loggable {
    public let tracer: Log.Tracer
    @usableFromInline
    let logger: Loggable
    @usableFromInline
    let compactedTracers: [Log.Tracer]

    public init(
        tracer: Log.Tracer, meta: [String: Log.String], logger: Loggable,
        file: String = #file, function: String = #function, line: UInt = #line
    ) {
        self.tracer = tracer

        if let tracedParentLogger = logger as? TracedLogger {
            compactedTracers = [ tracer ] + tracedParentLogger.compactedTracers
            self.logger = tracedParentLogger.logger
        } else {
            compactedTracers = [ tracer ]
            self.logger = logger
        }

        logger.update(tracer: tracer, meta: meta, file: file, function: function, line: line)
    }

    deinit {
        logger.finish(tracer: tracer)
    }

    @inlinable
    public func add(
        _ item: Log.Item, meta: @autoclosure () -> [String: Log.String]?, tracers: [Log.Tracer], date: Date,
        file: String, function: String, line: UInt
    ) {
        logger.add(item, meta: meta(), tracers: tracers + compactedTracers, date: date, file: file, function: function, line: line)
    }
}
