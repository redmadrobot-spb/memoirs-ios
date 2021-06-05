//
// Subscription
// MemoirSubscriptions
//
// Created by Alex Babaev on 05 June 2021.
// Copyright © 2021 Redmadrobot SPb. All rights reserved.
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
