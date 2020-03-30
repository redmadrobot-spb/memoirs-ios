//
//  InMemoryBuffering.swift
//  RobologsTest
//
//  Created by Vladislav Maltsev on 04.03.2020.
//  Copyright © 2020 RedMadRobot. All rights reserved.
//

/// Simplest buffering - just keeps log records in memory.
public class InMemoryBuffering: RemoteLoggerBuffering {
    private var records: [LogRecord] = []

    public init() {}

    var haveBufferedData: Bool {
        !records.isEmpty
    }

    func append(record: LogRecord) {
        records.append(record)
    }

    func retrieve(_ actions: @escaping ([LogRecord], @escaping (Bool) -> Void) -> Void) {
        records = []
        let pendedRecords = records
        actions(records) { isFinished in
            if !isFinished {
                self.records = pendedRecords + self.records
            }
        }
    }
}
