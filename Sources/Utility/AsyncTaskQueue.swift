//
// AsyncTaskQueue
// memoirs-ios
//
// Created by Alex Babaev on 25 June 2022.
// Copyright © 2022 Alex Babaev. All rights reserved.
//

import Foundation

extension DispatchSemaphore: @unchecked Sendable {}

public final class AsyncTaskQueue: @unchecked Sendable {
    private let syncExecution: Bool

    public init(syncExecution: Bool = false) {
        self.syncExecution = syncExecution
    }

    private let queue: DispatchQueue = .init(label: "AsyncTaskQueue")

    private var actions: [@Sendable () async -> Void] = []

    public func add(closure: @escaping @Sendable () async -> Void) {
        if syncExecution {
            let semaphore = DispatchSemaphore(value: 0)
            queue.async {
                self.actions.append(closure)
                self.startNext(semaphore: semaphore)
            }
            semaphore.wait()
        } else {
            queue.async {
                self.actions.append(closure)
                self.startNext(semaphore: nil)
            }
        }
    }

    public func flush() {
        isExecutingAllAtOnce = true
        if syncExecution {
            let semaphore = DispatchSemaphore(value: 0)
            startNext(semaphore: semaphore)
            semaphore.wait()
        } else {
            startNext(semaphore: nil)
        }
    }

    private var isExecutingAllAtOnce: Bool = false
    private var isExecuting: Bool = false

    private func startNext(semaphore: DispatchSemaphore?) {
        guard !isExecuting && !actions.isEmpty else {
            semaphore?.signal()
            return
        }

        isExecuting = true
        let closures: [@Sendable () async -> Void]
        if isExecutingAllAtOnce {
            closures = actions
            actions = []
        } else {
            closures = [ actions.removeFirst() ]
        }
        Task {
            for closure in closures {
                await closure()
            }
            isExecuting = false
            if isExecutingAllAtOnce && !actions.isEmpty {
                self.startNext(semaphore: semaphore)
            } else {
                isExecutingAllAtOnce = false
                queue.async {
                    self.startNext(semaphore: semaphore)
                }
            }
        }
    }
}