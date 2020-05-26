//
// NullRemoteLoggerBuffer
// Robologs
//
// Created by Alex Babaev on 26 May 2020.
// Copyright (c) 2020 Redmadrobot. All rights reserved.
//

import Foundation

class NullRemoteLoggerBuffer: RemoteLoggerBuffer {
    private(set) lazy var name: String = String(describing: type(of: self))
    let kind: RemoteLoggerBufferKind = .unknown

    func add(record: CachedLogMessage) {
    }

    func getNextBatch() -> (batchId: String, records: [CachedLogMessage])? {
        nil
    }

    func removeBatch(id: String) {
    }
}
