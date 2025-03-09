//
// AsyncTaskQueue
// memoirs-ios
//
// Created by Alex Babaev on 25 June 2022.
// Copyright © 2022 Alex Babaev. All rights reserved.
//

//import os
import Foundation

//public typealias AsyncTaskQueue = AsyncTaskQueueArray
public typealias AsyncTaskQueue = AsyncTaskQueueList
//public typealias AsyncTaskQueue = AsyncTaskQueueWithLocks

// most tested
public final class AsyncTaskQueueArray: @unchecked Sendable {
    private typealias Action = @Sendable () async throws -> Void

    var executeAlongsideCallback: (() -> Void)?

    private let memoir: Memoir

    public init(memoir: Memoir) {
        self.memoir = memoir
    }

    private let queue: DispatchQueue = .init(label: "AsyncTaskQueue")
    private var actions: [@Sendable () async throws -> Void] = []
    private var isExecuting: Bool = false

    public func add(closure: @escaping @Sendable () async throws -> Void) {
        queue.async {
            self.actions.append(closure)
            self.startNext()
        }
    }

    private func startNext() {
        guard !isExecuting && !actions.isEmpty else { return }

        isExecuting = true
        let closure: @Sendable () async throws -> Void = actions.removeFirst()
        Task {
            do {
                try await closure()
                executeAlongsideCallback?()
            } catch {
                memoir.error("Problem while executing queue task: \(error)")
            }
            queue.async {
                self.isExecuting = false
                if !self.actions.isEmpty {
                    self.startNext()
                }
            }
        }
    }
}

// fastest for now
public final class AsyncTaskQueueList: @unchecked Sendable {
    public typealias Action = @Sendable () async throws -> Void

    var executeAlongsideCallback: (() -> Void)?

    private class Item: @unchecked Sendable {
        let action: Action
        var next: Item?

        init(action: @escaping Action, next: Item? = nil) {
            self.action = action
            self.next = next
        }
    }

    private let memoir: Memoir

    public init(memoir: Memoir) {
        self.memoir = memoir
    }

    private let queue: DispatchQueue = .init(label: "AsyncTaskQueue")
    private var actionsHead: Item?
    private var actionsTail: Item?

    public func add(closure: @escaping Action) {
        queue.async { [self] in
            if actionsTail == nil {
                actionsTail = Item(action: closure)
                actionsHead = actionsTail
            } else {
                actionsTail?.next = Item(action: closure)
                actionsTail = actionsTail?.next
            }
            startNext()
        }
    }

    private var alreadyExecuting: Bool = false

    private func startNext() {
        guard !alreadyExecuting, let actionsHead else {
            return
        }

        alreadyExecuting = true
        self.actionsHead = actionsHead.next
        if self.actionsHead == nil {
            actionsTail = nil
        }
        execute(actionsHead.action)
    }

    private func execute(_ action: @escaping Action) {
        Task { [self] in
            do {
                try await action()
                executeAlongsideCallback?()
            } catch {
                memoir.error("Problem while executing queue task: \(error)")
            }
            queue.async { [self] in
                alreadyExecuting = false
                startNext()
            }
        }
    }
}

//// slowest for now
//public final class AsyncTaskQueueWithLocks: @unchecked Sendable {
//    public typealias Action = @Sendable () async throws -> Void
//
//    var executeAlongsideCallback: (() -> Void)?
//
//    private let memoir: Memoir
//
//    public init(memoir: Memoir) {
//        self.memoir = memoir
//    }
//
//    private var actions: [Action] = []
//    private let protectedState = OSAllocatedUnfairLock(initialState: Void())
//
//    public func add(closure: @escaping Action) {
//        protectedState.withLock {
//            actions.append(closure)
//        }
//
//        self.startNext()
//    }
//
//    private var isExecuting: Bool = false
//
//    private func startNext() {
//        let closureToExecute: Action? = protectedState.withLock {
//            let result = !isExecuting && !actions.isEmpty
//            if result {
//                isExecuting = true
//            }
//
//            return result ? actions.removeFirst() : nil
//        }
//        guard let closureToExecute else {
//            isExecuting = false
//            return
//        }
//
//        Task {
//            do {
//                try await closureToExecute()
//                executeAlongsideCallback?()
//            } catch {
//                memoir.error("Problem while executing queue task: \(error)")
//            }
//            let isEmpty = protectedState.withLock {
//                isExecuting = false
//                return actions.isEmpty
//            }
//            if !isEmpty {
//                startNext()
//            }
//        }
//    }
//}
