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

@available(iOS 13, *)
public struct TaskLocalMemoirContext {
    @TaskLocal
    public static var memoir: TracedMemoir!
}

@available(iOS 13, *)
public protocol TaskLocalContextTraceable {
    var tracer: Tracer { get }
    var memoir: TracedMemoir { get }

    func tracing<R>(operation: () async throws -> R, file: String, line: UInt) async throws -> R
}

@available(iOS 13, *)
public extension TaskLocalContextTraceable {
    var memoir: TracedMemoir { TaskLocalMemoirContext.memoir.with(tracer: tracer) }

    func tracing<R>(operation: () async throws -> R, file: String = #file, line: UInt = #line) async throws -> R {
        try await TaskLocalMemoirContext.$memoir.withValue(memoir, operation: operation, file: file, line: line)
    }

    func tracingRequest<R>(operation: () async throws -> R, file: String = #file, line: UInt = #line) async throws -> R {
        let memoir = TaskLocalMemoirContext.memoir.with(tracer: .request(trace: UUID().uuidString))
        return try await TaskLocalMemoirContext.$memoir.withValue(memoir, operation: operation, file: file, line: line)
    }

    func tracingDetached(operation: @escaping () async throws -> Void, file: String = #file, line: UInt = #line) {
        let memoir = TaskLocalMemoirContext.memoir
        Task.detached {
            try await TaskLocalMemoirContext.$memoir.withValue(memoir, operation: operation, file: file, line: line)
        }
    }
}

@available(iOS 13, *)
public protocol ObjectContextTraceable {
    var tracer: Tracer! { get }
    var memoir: TracedMemoir! { get }

    func tracing(operation: @escaping () async throws -> Void, file: String, line: UInt)
}

@available(iOS 13, *)
public extension ObjectContextTraceable {
    func tracing(operation: @escaping () async throws -> Void, file: String = #file, line: UInt = #line) {
        Task.detached {
            try await TaskLocalMemoirContext.$memoir.withValue(self.memoir, operation: operation, file: file, line: line)
        }
    }
}

#endif
