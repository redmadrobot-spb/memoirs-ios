//
// Context
// Memoirs
//
// Created by Alex Babaev on 18 November 2021.
// Copyright © 2021 Redmadrobot SPb. All rights reserved.
// Copyright © 2021 Alex Babaev. All rights reserved.
// License: MIT License, https://github.com/redmadrobot-spb/memoirs-ios/blob/main/LICENSE
//

import Foundation

public struct MemoirContext {
    public let memoir: TracedMemoir

    public init(memoir: TracedMemoir) {
        self.memoir = memoir
    }

    public func appending(tracer: Tracer) -> MemoirContext {
        MemoirContext(memoir: memoir.with(tracer: tracer))
    }
}

#if swift(>=5.5)

@available(iOS 15, *)
public struct TaskLocalMemoirContext {
    @TaskLocal
    public static var memoir: TracedMemoir?
}

@available(iOS 15, *)
public protocol TaskTraceable {
    var memoir: ContextMemoir { get }

    static func requestTracer(parentTracer: String?) -> String

    func tracing<R>(operation: () async throws -> R, file: String, line: UInt) async throws -> R
}

@available(iOS 15, *)
public extension TaskTraceable {
    static func requestTracer(parentTracer: String? = nil) -> String {
        let traceId = (0 ..< 16)
            .map { _ in UInt8.random(in: UInt8.min ... UInt8.max) }
            .map { String(format: "%02hhx", $0) }
            .joined()
        let parentId = (0 ..< 8)
            .map { _ in UInt8.random(in: UInt8.min ... UInt8.max) }
            .map { String(format: "%02hhx", $0) }
            .joined()
        return "00-\(traceId)-\(parentId)-00"
    }

    func tracing<R>(operation: () async throws -> R, file: String = #file, line: UInt = #line) async throws -> R {
        let memoir = TaskLocalMemoirContext.memoir?.with(tracer: memoir.tracedMemoir.tracer) ?? memoir.tracedMemoir
        return try await TaskLocalMemoirContext.$memoir.withValue(memoir, operation: operation, file: file, line: line)
    }

    func tracingRequest<R>(
        previousTracer: String? = nil, operation: () async throws -> R, file: String = #file, line: UInt = #line
    ) async throws -> R {
        let tracer: Tracer = .request(trace: Self.requestTracer(parentTracer: previousTracer))
        let memoir = TaskLocalMemoirContext.memoir?.with(tracer: tracer)
        return try await TaskLocalMemoirContext.$memoir.withValue(memoir, operation: operation, file: file, line: line)
    }

    func tracingDetached(operation: @escaping () async throws -> Void, file: String = #file, line: UInt = #line) {
        let memoir = TaskLocalMemoirContext.memoir
        Task.detached {
            try await TaskLocalMemoirContext.$memoir.withValue(memoir, operation: operation, file: file, line: line)
        }
    }
}

@available(iOS 15, *)
public protocol ObjectTraceable {
    var memoir: ContextMemoir! { get }

    func tracing(operation: @escaping () async throws -> Void, file: String, line: UInt)
}

@available(iOS 15, *)
public extension ObjectTraceable {
    func tracing(operation: @escaping () async throws -> Void, file: String = #file, line: UInt = #line) {
        Task.detached {
            let memoir = TaskLocalMemoirContext.memoir?.with(tracer: memoir.tracedMemoir.tracer) ?? memoir.tracedMemoir
            try await TaskLocalMemoirContext.$memoir.withValue(memoir, operation: operation, file: file, line: line)
        }
    }
}

#endif
