//
// RemoteLoggingBuffer
// Robologs
//
// Created by Alex Babaev on 25 April 2020.
// Copyright © 2020 Redmadrobot SPb. All rights reserved.
//

import Foundation

protocol RemoteLoggerBuffer {
    func add(message: SerializedLogMessage)
    func getNextBatch() -> (batchId: String, records: [SerializedLogMessage])?
    func removeBatch(id: String)
}
