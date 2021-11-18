//
// Context
// Memoirs
//
// Created by Alex Babaev on 18 November 2021.
// Copyright © 2021 Alex Babaev. All rights reserved.
//

import Foundation

public struct MemoirContext {
    public let memoir: TracedMemoir

    public func appending(tracer: Tracer) -> MemoirContext {
        MemoirContext(memoir: memoir.with(tracer: tracer))
    }
}
