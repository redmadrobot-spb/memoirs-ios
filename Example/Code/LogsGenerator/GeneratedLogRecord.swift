//
//  GeneratedLogRecord.swift
//  Example
//
//  Created by Roman Mazeev on 30.03.2020.
//  Copyright © 2020 Redmadrobot. All rights reserved.
//

import Robologs

struct GeneratedLogRecord {
    let level: Level
    let label: String
    let message: LogString
    let meta: [String: LogString]?

    init(level: Level, label: String = "", message: LogString, meta: [String: LogString]? = nil) {
        self.level = level
        self.label = label
        self.message = message
        self.meta = meta
    }
}
