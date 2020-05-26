//
// RemoteLoggingBuffer
// Robologs
//
// Created by Alex Babaev on 25 April 2020.
// Copyright © 2020 Redmadrobot SPb. All rights reserved.
//

import Foundation

enum RemoteLoggerBufferKind {
    case live
    case archive
    case unknown
}

protocol RemoteLoggerBuffer {
    var name: String { get }
    var kind: RemoteLoggerBufferKind { get }

    func add(record: CachedLogMessage)
    func getNextBatch() -> (batchId: String, records: [CachedLogMessage])?
    func removeBatch(id: String)
}
