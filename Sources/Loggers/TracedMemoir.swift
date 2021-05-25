//
// TracedMemoir
// Robologs
//
// Created by Alex Babaev on 22 May 2021.
// Copyright © 2021 Alex Babaev. All rights reserved.
//

import Foundation

/// Protocol that adds a tracer to every item that passes through.
public protocol Traceable {
    var tracer: Tracer { get }
}

public class TracedMemoir: Memoir, Traceable {
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

    public let tracer: Tracer
    private let tracerHolder: TracerHolder

    @usableFromInline
    let memoir: Memoir
    @usableFromInline
    let compactedTracerHolders: [TracerHolder]

    public init(
        tracer: Tracer, meta: [String: SafeString], memoir: Memoir,
        file: String = #file, function: String = #function, line: UInt = #line
    ) {
        self.tracer = tracer
        memoir.update(tracer: tracer, meta: meta, file: file, function: function, line: line)
        tracerHolder = TracerHolder(tracer: tracer) {
            memoir.finish(tracer: tracer)
        }

        if let tracedParentMemoir = memoir as? TracedMemoir {
            compactedTracerHolders = [ tracerHolder ] + tracedParentMemoir.compactedTracerHolders
            self.memoir = tracedParentMemoir.memoir
        } else {
            compactedTracerHolders = [ tracerHolder ]
            self.memoir = memoir
        }
    }

    public convenience init(label: String, memoir: Memoir, file: String = #file, function: String = #function, line: UInt = #line) {
        self.init(tracer: .label(label), meta: [:], memoir: memoir, file: file, function: function, line: line)
    }

    public convenience init(object: Any, memoir: Memoir, file: String = #file, function: String = #function, line: UInt = #line) {
        self.init(label: String(describing: type(of: object)), memoir: memoir, file: file, function: function, line: line)
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
