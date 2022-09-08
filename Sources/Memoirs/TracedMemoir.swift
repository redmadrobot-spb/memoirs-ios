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

public final class TracedMemoir: Memoir {
    actor TraceData {
        private actor TracerSubscription {
            private let onDispose: @Sendable () -> Void

            public init(onDispose: @escaping @Sendable () -> Void) {
                self.onDispose = onDispose
            }

            deinit {
                onDispose()
            }
        }

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

        private func subscribeOnUpdates(listener: @escaping @Sendable () async -> Void) -> TracerSubscription {
            let id = UUID().uuidString
            updateSubscriptions[id] = listener
            return TracerSubscription { [self] in
                Task {
                    await unsubscribe(from: id)
                }
            }
        }

        private func unsubscribe(from id: String) {
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

    let traceData: TraceData

    private let memoir: Memoir
    public var tracer: Tracer {
        get async {
            await traceData.tracer
        }
    }
    public var tracers: [Tracer] {
        get async {
            await traceData.allTracers
        }
    }

    private let asyncTaskQueue: AsyncTaskQueue

    private init(traceData: TraceData, memoir: Memoir, useSyncOutput: Bool = false) {
        self.traceData = traceData
        self.memoir = memoir
        asyncTaskQueue = .init(syncExecution: useSyncOutput)
    }

    public init(
        tracer: Tracer, meta: [String: SafeString] = [:], memoir: Memoir,
        useSyncOutput: Bool = false,
        file: String = #fileID, function: String = #function, line: UInt = #line
    ) {
        asyncTaskQueue = .init(syncExecution: useSyncOutput)

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

    public convenience init(
        label: String, memoir: Memoir,
        useSyncOutput: Bool = false,
        file: String = #fileID, function: String = #function, line: UInt = #line
    ) {
        self.init(
            tracer: .label(label), meta: [:], memoir: memoir,
            useSyncOutput: useSyncOutput,
            file: file, function: function, line: line
        )
    }

    public convenience init(
        object: Any, memoir: Memoir,
        useSyncOutput: Bool = false,
        file: String = #fileID, function: String = #function, line: UInt = #line
    ) {
        let tracer = Memoirs.tracer(for: object)
        self.init(
            tracer: tracer, meta: [:], memoir: memoir,
            useSyncOutput: useSyncOutput,
            file: file, function: function, line: line
        )
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
        asyncTaskQueue.add {
            let selfTracers = await self.traceData.allTracers
            self.memoir.append(
                item, meta: meta, tracers: tracers + selfTracers, timeIntervalSinceReferenceDate: timeIntervalSinceReferenceDate,
                file: file, function: function, line: line
            )
        }
    }
}
