//
// AsyncTaskQueue
// memoirs-ios
//
// Created by Alex Babaev on 25 June 2022.
// Copyright © 2022 Alex Babaev. All rights reserved.
//

import Foundation

public final class AsyncTaskQueue: @unchecked Sendable {
    private let queue: DispatchQueue = .init(label: "AsyncTaskQueue")

    private var actions: [@Sendable () async -> Void] = []

    public func add(closure: @escaping @Sendable () async -> Void) {
        queue.async {
            self.actions.append(closure)
            self.startNext()
        }
    }

    public func flush() {
        isExecutingAllAtOnce = true
        startNext()
    }

    private var isExecutingAllAtOnce: Bool = false
    private var isExecuting: Bool = false

    private func startNext() {
        guard !isExecuting && !actions.isEmpty else { return }

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
                self.startNext()
            } else {
                isExecutingAllAtOnce = false
                queue.async {
                    self.startNext()
                }
            }
        }
    }
}
