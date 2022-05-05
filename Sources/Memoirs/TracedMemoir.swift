//
// TracedMemoir
// Memoirs
//
// Created by Alex Babaev on 22 May 2021.
// Copyright © 2021 Redmadrobot SPb. All rights reserved.
// Copyright © 2021 Alex Babaev. All rights reserved.
// License: MIT License, https://github.com/redmadrobot-spb/memoirs-ios/blob/main/LICENSE
//

import Foundation

actor TracerSubscription {
    private let onDispose: @Sendable () async -> Void

    public init(onDispose: @escaping @Sendable () async -> Void) {
        self.onDispose = onDispose
    }

    deinit {
        Task {
            await onDispose()
        }
    }
}

actor TraceData {
    private(set) var tracer: Tracer
    private(set) var parent: TraceData?

    private var updateSubscriptions: [String: @Sendable () async -> Void] = [:]
    private var completionHandler: (@Sendable () async -> Void)?

    private var internalTracerListCache: [Tracer]?
    var allTracers: [Tracer] {
        get async {
            if let cached = internalTracerListCache {
                return cached
            } else {
                await updateTracerListCache()
                return internalTracerListCache ?? []
            }
        }
    }

    private var parentUpdateSubscription: TracerSubscription?

    init(tracer: Tracer, parent: TraceData?) {
        self.tracer = tracer
        self.parent = parent
    }

    func postInitialize() async {
        parentUpdateSubscription = await parent?.subscribeOnUpdates { [weak self] in
            await self?.updateTracerListCache()
        }
    }

    func subscribeOnUpdates(listener: @escaping @Sendable () async -> Void) -> TracerSubscription {
        let id = UUID().uuidString
        updateSubscriptions[id] = listener
        return TracerSubscription { [self] in
            await unsubscribe(from: id)
        }
    }

    private func unsubscribe(from id: String) async {
        updateSubscriptions[id] = nil
    }

    deinit {
        if let completionHandler = completionHandler {
            Task {
                await completionHandler()
            }
        }
    }

    func update(tracer: Tracer) async {
        self.tracer = tracer
        await updateTracerListCache()
    }

    func update(completionHandler: @escaping @Sendable () async -> Void) {
        self.completionHandler = completionHandler
    }

    private func updateTracerListCache() async {
        internalTracerListCache = [ tracer ] + (await parent?.allTracers ?? [])
        for subscription in updateSubscriptions.values {
            await subscription()
        }
    }
}

public final class TracedMemoir: Memoir {
    let traceData: TraceData

    private let memoir: Memoir

    private init(traceData: TraceData, memoir: Memoir) {
        self.traceData = traceData
        self.memoir = memoir
    }

    public init(
        tracer: Tracer, meta: [String: SafeString] = [:], memoir: Memoir,
        file: String = #fileID, function: String = #function, line: UInt = #line
    ) {
        if let parentMemoir = memoir as? TracedMemoir {
            traceData = .init(tracer: tracer, parent: parentMemoir.traceData)
            self.memoir = parentMemoir.memoir
        } else {
            traceData = .init(tracer: tracer, parent: nil)
            self.memoir = memoir
        }

        Task { [self] in
            await traceData.postInitialize()
            await traceData.update(completionHandler: { [self] in
                await self.memoir.finish(tracer: tracer, tracers: traceData.allTracers)
            })
            await self.memoir.update(tracer: tracer, meta: meta, tracers: traceData.allTracers, file: file, function: function, line: line)
        }
    }

    public convenience init(label: String, memoir: Memoir, file: String = #fileID, function: String = #function, line: UInt = #line) {
        self.init(tracer: .label(label), meta: [:], memoir: memoir, file: file, function: function, line: line)
    }

    public convenience init(object: Any, memoir: Memoir, file: String = #fileID, function: String = #function, line: UInt = #line) {
        let tracer = Memoirs.tracer(for: object)
        self.init(tracer: tracer, meta: [:], memoir: memoir, file: file, function: function, line: line)
    }

    public func with(tracer: Tracer) -> TracedMemoir {
        let traceData = TraceData(tracer: tracer, parent: traceData)
        Task {
            await traceData.postInitialize()
        }
        return TracedMemoir(traceData: traceData, memoir: memoir)
    }

    public func updateTracer(to tracer: Tracer) async {
        await traceData.update(tracer: tracer)
    }

    public func append(
        _ item: MemoirItem, meta: @autoclosure () -> [String: SafeString]?, tracers: [Tracer], timeIntervalSinceReferenceDate: TimeInterval,
        file: String, function: String, line: UInt
    ) {
        let meta = meta()
        Task { [item, meta, tracers, timeIntervalSinceReferenceDate, file, function, line] in
            await memoir.append(
                item, meta: meta, tracers: tracers + traceData.allTracers, timeIntervalSinceReferenceDate: timeIntervalSinceReferenceDate,
                file: file, function: function, line: line
            )
        }
    }
}
