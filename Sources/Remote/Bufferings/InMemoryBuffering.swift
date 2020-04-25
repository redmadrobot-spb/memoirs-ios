//
//  InMemoryBuffering.swift
//  RobologsTest
//
//  Created by Vladislav Maltsev on 04.03.2020.
//  Copyright © 2020 RedMadRobot. All rights reserved.
//

/// Simplest buffering - just keeps log records in memory.
class InMemoryBuffering: RemoteLoggerBuffer {
    private var records: [LogRecord] = []

    var haveBufferedData: Bool {
        !records.isEmpty
    }

    func append(record: LogRecord) {
        records.append(record)
    }

    func retrieve(_ actions: @escaping ([LogRecord], @escaping (Bool) -> Void) -> Void) {
        let pendedRecords = records
        records = []
        actions(pendedRecords) { isFinished in
            if !isFinished {
                self.records = pendedRecords + self.records
            }
        }
    }
}
