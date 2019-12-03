//
//  OSLogLogger.swift
//  Robologs
//
//  Created by Dmitry Shadrin on 03.12.2019.
//  Copyright © 2019 Redmadrobot. All rights reserved.
//

import Foundation
import os.log

@available(iOS 12.0, *)
class OSLogLogger: Logger {
    private let subsystem: String
    private let queue: DispatchQueue
    private var loggers: [ String: OSLog ] = [:]

    init(subsystem: String) {
        self.subsystem = subsystem
        queue = DispatchQueue(label: subsystem, attributes: .concurrent)
    }

    func log(
        priority: Priority,
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line,
        label: () -> String,
        message: () -> String,
        meta: () -> [ String: Any ]?
    ) {
        let logLabel = label()
        let description = prepareMessage(priority, "\(file):\(function):\(line)", logLabel, message(), meta())
        os_log(logType(from: priority), log: logger(with: logLabel), "%{public}@", description)
    }

    private func logType(from priority: Priority) -> OSLogType {
        switch priority {
            case .verbose:
                return .debug
            case .debug:
                return .debug
            case .info:
                return .info
            case .warning:
                return .default
            case .error:
                return .error
            case .critical:
                return .fault
        }
    }

    private func logger(with label: String) -> OSLog {
        if let logger = loggers[label] {
            return logger
        } else {
            let logger = OSLog(subsystem: subsystem, category: label)
            loggers[label] = logger
            return logger
        }
    }
}
