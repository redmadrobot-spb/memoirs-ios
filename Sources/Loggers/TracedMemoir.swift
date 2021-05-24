//
// TracedMemoir
// Robologs
//
// Created by Alex Babaev on 22 May 2021.
// Copyright © 2021 Alex Babaev. All rights reserved.
//

import Foundation

public class TracedMemoir: Memoir {
    public let tracer: Tracer

    @usableFromInline
    let memoir: Memoir
    @usableFromInline
    let compactedTracers: [Tracer]

    public init(
        tracer: Tracer, meta: [String: SafeString], memoir: Memoir,
        file: String = #file, function: String = #function, line: UInt = #line
    ) {
        self.tracer = tracer

        if let tracedParentMemoir = memoir as? TracedMemoir {
            compactedTracers = [ tracer ] + tracedParentMemoir.compactedTracers
            self.memoir = tracedParentMemoir.memoir
        } else {
            compactedTracers = [ tracer ]
            self.memoir = memoir
        }

        memoir.update(tracer: tracer, meta: meta, file: file, function: function, line: line)
    }

    public convenience init(label: String, memoir: Memoir, file: String = #file, function: String = #function, line: UInt = #line) {
        self.init(tracer: .label(label), meta: [:], memoir: memoir, file: file, function: function, line: line)
    }

    public convenience init(object: Any, memoir: Memoir, file: String = #file, function: String = #function, line: UInt = #line) {
        self.init(label: String(describing: type(of: object)), memoir: memoir, file: file, function: function, line: line)
    }

    deinit {
        memoir.finish(tracer: tracer)
    }

    @inlinable
    public func append(
        _ item: MemoirItem, meta: @autoclosure () -> [String: SafeString]?, tracers: [Tracer], date: Date,
        file: String, function: String, line: UInt
    ) {
        memoir.append(item, meta: meta(), tracers: tracers + compactedTracers, date: date, file: file, function: function, line: line)
    }
}
