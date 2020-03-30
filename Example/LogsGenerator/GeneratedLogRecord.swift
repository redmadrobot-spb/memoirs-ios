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
    let message: String
    let meta: [String: String]?

    init(level: Level, label: String = "", message: String, meta: [String: String]? = nil) {
        self.level = level
        self.label = label
        self.message = message
        self.meta = meta
    }
}
