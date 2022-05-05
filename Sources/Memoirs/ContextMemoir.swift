//
// ContextMemoir
// memoirs-ios
//
// Created by Alex Babaev on 12 December 2021.
// Copyright © 2021 Alex Babaev. All rights reserved.
//

import Foundation

#if swift(>=5.5)

@available(iOS 15, *)
public struct ContextMemoir: Memoir {
    public let tracedMemoir: TracedMemoir

    public init(tracedMemoir: TracedMemoir) {
        self.tracedMemoir = tracedMemoir
    }

    public func append(
        _ item: MemoirItem, meta: @autoclosure () -> [String: SafeString]?, tracers: [Tracer], timeIntervalSinceReferenceDate: TimeInterval,
        file: String, function: String, line: UInt
    ) {
        let meta = meta()
        Task {
            let tracer = await tracedMemoir.traceData.tracer
            let memoir = TaskLocalMemoirContext.memoir?.with(tracer: tracer) ?? tracedMemoir
            memoir.append(item, meta: meta, tracers: tracers, timeIntervalSinceReferenceDate: timeIntervalSinceReferenceDate, file: file, function: function, line: line)
        }
    }
}

#endif
