//
// BufferLogger
// Example
//
// Created by Roman Mazeev on 28.03.2020.
// Copyright © 2020 Redmadrobot SPb. All rights reserved.
//

import Robologs
import Foundation

class BufferLogger: Logger {
    private let formatter: DateFormatter
    private let updateInterval: TimeInterval = 0.5

    var changeHandler: (_ logs: [String]) -> Void = { _ in }

    init() {
        formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        notify(needRepeat: true)
    }

    private let maxLastLogsCount = 50
    private(set) var lastLogs: [String] = []

    func log(
        level: Level,
        _ message: @autoclosure () -> LogString,
        label: String,
        meta: @autoclosure () -> [String: LogString]? = nil,
        file: String = #file, function: String = #function, line: UInt = #line
    ) {
        let context = collectContext(file: "SomeFile", function: "foo()", line: 42)
        let description = concatenateData(
            time: formatter.string(from: Date()), level: level, message: message, label: label, meta: meta, context: context,
            isSensitive: false
        )
        lastLogs.append(description)
        if lastLogs.count > maxLastLogsCount {
            notify(needRepeat: false)
        }
    }

    @objc
    private func notify(needRepeat: Bool) {
        if !lastLogs.isEmpty {
            let logs = lastLogs
            lastLogs = []
            changeHandler(logs)
        }

        if needRepeat {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                guard let self = self else { return }

                self.notify(needRepeat: true)
            }
        }
    }
}
