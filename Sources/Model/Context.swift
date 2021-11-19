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
