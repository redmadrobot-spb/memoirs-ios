//
// Context
// Memoirs
//
// Created by Alex Babaev on 18 November 2021.
// Copyright © 2021 Alex Babaev. All rights reserved.
//

import Foundation

struct MemoirContext {
    let memoir: TracedMemoir

    func appending(tracer: Tracer) -> MemoirContext {
        MemoirContext(memoir: memoir.with(tracer: tracer))
    }
}
