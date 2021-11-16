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
        var completionHandler: (() -> Void)?

        init(tracer: Tracer) {
            self.tracer = tracer
        }

        deinit {
            completionHandler?()
        }
    }

    private let tracerHolder: TracerHolder
    @usableFromInline
    let compactedTracerHolders: [TracerHolder]

    @usableFromInline
    let memoir: Memoir

    public var tracers: [Tracer] { compactedTracerHolders.map { $0.tracer } }

    private init(currentTracerHolder: TracerHolder, parentTracerHolders: [TracerHolder], memoir: Memoir) {
        tracerHolder = currentTracerHolder
        compactedTracerHolders = [ currentTracerHolder ] + parentTracerHolders
        self.memoir = memoir
    }

    convenience public init(localMemoir: TracedMemoir, callStackMemoir: TracedMemoir) {
        self.init(
            currentTracerHolder: localMemoir.tracerHolder,
            parentTracerHolders: callStackMemoir.compactedTracerHolders,
            memoir: callStackMemoir.memoir
        )
    }

    public init(
        tracer: Tracer, meta: [String: SafeString], memoir: Memoir,
        file: String = #fileID, function: String = #function, line: UInt = #line
    ) {
        tracerHolder = TracerHolder(tracer: tracer)

        let selfMemoir: Memoir
        if let tracedParentMemoir = memoir as? TracedMemoir {
            compactedTracerHolders = [ tracerHolder ] + tracedParentMemoir.compactedTracerHolders
            selfMemoir = tracedParentMemoir.memoir
        } else {
            compactedTracerHolders = [ tracerHolder ]
            selfMemoir = memoir
        }
        self.memoir = selfMemoir

        let currentTracers: [Tracer] = compactedTracerHolders.map { $0.tracer }
        tracerHolder.completionHandler = {
            selfMemoir.finish(tracer: tracer, tracers: currentTracers)
        }
        selfMemoir.update(tracer: tracer, meta: meta, tracers: currentTracers, file: file, function: function, line: line)
    }

    public func with(tracer: Tracer) -> TracedMemoir {
        TracedMemoir(currentTracerHolder: TracerHolder(tracer: tracer), parentTracerHolders: compactedTracerHolders, memoir: memoir)
    }

    public convenience init(label: String, memoir: Memoir, file: String = #fileID, function: String = #function, line: UInt = #line) {
        self.init(tracer: .label(label), meta: [:], memoir: memoir, file: file, function: function, line: line)
    }

    public convenience init(object: Any, memoir: Memoir, file: String = #fileID, function: String = #function, line: UInt = #line) {
        let tracer = tracer(for: object)
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
