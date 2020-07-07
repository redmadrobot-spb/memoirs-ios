//
// Subscriptions
// Robologs
//
// Created by Vladislav Maltsev on 01.04.2020.
// Copyright © 2020 Redmadrobot SPb. All rights reserved.
//

import Foundation

public class Subscription {
    private let onDispose: () -> Void

    public init(onDispose: @escaping () -> Void) {
        self.onDispose = onDispose
    }

    deinit {
        onDispose()
    }
}

class Subscribers<T> {
    private var subscriberActions: [UUID: (T) -> Void] = [:]

    func subscribe(action: @escaping (T) -> Void) -> Subscription {
        let uuid = UUID()
        subscriberActions[uuid] = action

        return Subscription { [weak self] in
            self?.subscriberActions[uuid] = nil
        }
    }

    func fire(_ value: T) {
        subscriberActions.values.forEach { $0(value) }
    }
}
