//
//  DiagnosticLogger.swift
//  Example
//
//  Created by Roman Mazeev on 28.03.2020.
//  Copyright © 2020 Redmadrobot. All rights reserved.
//

import Robologs
import Foundation

class DiagnosticLogger: Logger {
    init(onChange: @escaping (DiagnosticLogger) -> Void) {
        self.onChange = onChange
        timer = Timer.scheduledTimer(
            timeInterval: updateInterval,
            target: self,
            selector: #selector(notify),
            userInfo: nil,
            repeats: true
        )
    }

    private let updateInterval: TimeInterval = 0.5
    private let maxLastLogsCount = 20
    private let onChange: (DiagnosticLogger) -> Void
    private var timer: Timer!

    private(set) var lastLogs: [String] = []
    private(set) var totalCount: Int = 0

    func log(
        level: Level,
        _ message: @autoclosure () -> LogString,
        label: String,
        meta: @autoclosure () -> [String: LogString]? = nil,
        file: String = #file, function: String = #function, line: UInt = #line
    ) {
        totalCount += 1

        let context = collectContext(file: file, function: function, line: line)
        let description = concatenateData(
            time: "\(Date())", level: level, message: message, label: label, meta: meta, context: context, isSensitive: false
        )
        if lastLogs.count >= maxLastLogsCount {
            lastLogs = lastLogs.suffix(maxLastLogsCount - 1)
        }
        lastLogs.append(description)
    }

    func reset() {
        lastLogs = []
        totalCount = 0
    }

    @objc private func notify() {
        onChange(self)
    }
}
