//
// NullRemoteLoggerBuffer
// Robologs
//
// Created by Alex Babaev on 26 May 2020.
// Copyright (c) 2020 Redmadrobot. All rights reserved.
//

import Foundation

class NullRemoteLoggerBuffer: RemoteLoggerBuffer {
    func add(message: SerializedLogMessage) {
    }

    func getNextBatch() -> (batchId: String, records: [SerializedLogMessage])? {
        nil
    }

    func removeBatch(id: String) {
    }
}
