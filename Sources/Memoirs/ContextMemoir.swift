//
// ContextMemoir
// memoirs-ios
//
// Created by Alex Babaev on 12 December 2021.
// Copyright © 2021 Alex Babaev. All rights reserved.
//

import Foundation

#if swift(>=5.5)

@available(iOS 13, *)
public struct ContextMemoir: Memoir {
    public let tracedMemoir: TracedMemoir

    public init(tracedMemoir: TracedMemoir) {
        self.tracedMemoir = tracedMemoir
    }

    public func append(
        _ item: MemoirItem, meta: @autoclosure () -> [String: SafeString]?, tracers: [Tracer], date: Date,
        file: String, function: String, line: UInt
    ) {
        (TaskLocalMemoirContext.memoir?.with(tracer: tracedMemoir.tracer) ?? tracedMemoir)
            .append(item, meta: meta(), tracers: tracers, date: date, file: file, function: function, line: line)
    }
}

#endif
