//
// TracedMemoir
// Memoirs
//
// Created by Alex Babaev on 22 May 2021.
// Copyright © 2021 Redmadrobot SPb. All rights reserved.
// License: MIT License, https://github.com/redmadrobot-spb/memoirs-ios/blob/main/LICENSE
//

import Foundation

open class TracedMemoir: Memoir {
    @usableFromInline
    class TracerHolder {
        @usableFromInline
        var tracer: Tracer
        var completionHandler: () -> Void

        init(tracer: Tracer, completionHandler: @escaping () -> Void) {
            self.tracer = tracer
            self.completionHandler = completionHandler
        }

        deinit {
            completionHandler()
        }
    }

    private let tracerHolder: TracerHolder
    @usableFromInline
    let compactedTracerHolders: [TracerHolder]

    @usableFromInline
    let memoir: Memoir

    public init(
        tracer: Tracer, meta: [String: SafeString], memoir: Memoir,
        file: String = #fileID, function: String = #function, line: UInt = #line
    ) {
        memoir.update(tracer: tracer, meta: meta, file: file, function: function, line: line)
        tracerHolder = TracerHolder(tracer: tracer) {
            memoir.finish(tracer: tracer, file: file, function: function, line: line)
        }

        if let tracedParentMemoir = memoir as? TracedMemoir {
            compactedTracerHolders = [ tracerHolder ] + tracedParentMemoir.compactedTracerHolders
            self.memoir = tracedParentMemoir.memoir
        } else {
            compactedTracerHolders = [ tracerHolder ]
            self.memoir = memoir
        }
    }

    public convenience init(label: String, memoir: Memoir, file: String = #fileID, function: String = #function, line: UInt = #line) {
        self.init(tracer: .label(label), meta: [:], memoir: memoir, file: file, function: function, line: line)
    }

    public convenience init(object: Any, memoir: Memoir, file: String = #fileID, function: String = #function, line: UInt = #line) {
        let tracer = tracer(forObject: object)
        self.init(tracer: tracer, meta: [:], memoir: memoir, file: file, function: function, line: line)
    }

    public func updateTracer(to tracer: Tracer) {
        tracerHolder.tracer = tracer
    }

    @inlinable
    public func append(
        _ item: MemoirItem, meta: @autoclosure () -> [String: SafeString]?, tracers: [Tracer], date: Date,
        file: String, function: String, line: UInt
    ) {
        memoir.append(
            item, meta: meta(), tracers: tracers + compactedTracerHolders.map { $0.tracer }, date: date,
            file: file, function: function, line: line
        )
    }
}
