//
//  InMemoryBuffering.swift
//  RobologsTest
//
//  Created by Vladislav Maltsev on 04.03.2020.
//  Copyright © 2020 RedMadRobot. All rights reserved.
//

class InMemoryBuffering: RemoteLoggerBuffering {
    private var records: [LogRecord] = []

    var haveBufferedData: Bool {
        !records.isEmpty
    }

    func append(record: LogRecord) {
        records.append(record)
    }

    func retrieve(_ actions: @escaping ([LogRecord], @escaping (Bool) -> Void) -> Void) {
        actions(records) { finished in
            if finished {
                self.records = []
            }
        }
    }
}
