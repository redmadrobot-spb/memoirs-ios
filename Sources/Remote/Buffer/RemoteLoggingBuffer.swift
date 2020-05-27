//
// RemoteLoggingBuffer
// Robologs
//
// Created by Alex Babaev on 25 April 2020.
// Copyright © 2020 Redmadrobot SPb. All rights reserved.
//

import Foundation

protocol RemoteLoggerBuffer {
    func add(message: CachedLogMessage)
    func getNextBatch() -> (batchId: String, records: [CachedLogMessage])?
    func removeBatch(id: String)
}
