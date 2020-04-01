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
        label: String,
        message: () -> LogString,
        meta: () -> [String: LogString]?,
        file: String,
        function: String,
        line: UInt
    ) {
        totalCount += 1

        let context = [ file, function, (line == 0 ? "" : "\(line)") ].filter { !$0.isEmpty }.joined(separator: ":")
        let description = [ "\(Date())", "\(level)", context, "\(label)", "\(message())", meta().map { $0.isEmpty ? "" : "\($0)" } ]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
            .joined(separator: " ")
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
