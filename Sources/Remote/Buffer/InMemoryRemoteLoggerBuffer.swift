//
// InMemoryRemoteLoggerBuffer
// RobologsTest
//
// Created by Vladislav Maltsev on 04.03.2020.
// Copyright © 2020 Redmadrobot SPb. All rights reserved.
//

class InMemoryRemoteLoggerBuffer: RemoteLoggerBuffer {
    private(set) lazy var name: String = String(describing: type(of: self))
    let kind: RemoteLoggerBufferKind = .live

    var isEmpty: Bool { records.isEmpty }

    private let maxRecordsCount: Int

    init(maxRecordsCount: Int = 1000) {
        self.maxRecordsCount = maxRecordsCount
    }

    private var records: [CachedLogMessage] = []

    func add(record: CachedLogMessage) {
        records.append(record)
        if records.count > maxRecordsCount {
            records = records.suffix(records.count - maxRecordsCount)
        }
    }

    func getNextBatch() -> (batchId: String, records: [CachedLogMessage])? {
        if records.isEmpty {
            return nil
        } else {
            return ("WhateverId", records)
        }
    }

    func removeBatch(id: String) {
        records = []
    }
}
